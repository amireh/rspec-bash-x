require 'open3'
require 'expect'
require 'tempfile'
require_relative './fd'
require_relative './open3'
require_relative './noisy_thread'
require_relative './message_decoder'

module RSpec
  module Bash
    class ScriptEvaluator
      BLOCK_SIZE  = 1024
      CONDITIONAL_EXPR_STUB = 'conditional_expr'.freeze
      FRAME_NAME  = 1
      FRAME_ARG   = 2
      FRAME_TRACE = 3
      MESSAGE_REQ = '<rspec-bash::req>'.freeze
      MESSAGE_ACK = '<rspec-bash::ack>'.freeze

      # (String, Object?): Boolean
      #
      # @param [String] script
      # @param [Hash?] options
      # @param [Number?] options.read_fd
      # @param [Number?] options.write_fd
      # @param [Number?] options.throttle
      def eval(script, args = [], **opts)
        file = Tempfile.new('rspec_bash')
        file.write(script.to_s)
        file.close
        verbose = opts.fetch(:verbose, Bash.configuration.verbose)

        bus_file = Tempfile.new("rspec_bash#{File.basename(script.source_file).gsub(/\W+/, '_')}")
        bus_file.close

        Bash::Open3.popen3X([ '/usr/bin/env', 'bash', file.path ].concat(args), {
          read_fd: opts.fetch(:read_fd, Bash.configuration.read_fd),
          write_fd: opts.fetch(:write_fd, Bash.configuration.write_fd)
        }) do |input, stdout, stderr, r2b, b2r, wait_thr|
          workers = []

          # transmit stdout
          workers << NoisyThread.new do
            FD.poll(stdout, throttle: Bash.configuration.throttle) do
              buffer = stdout.read_nonblock(BLOCK_SIZE)

              script.stdout << buffer

              if verbose
                STDOUT.write buffer
                STDOUT.flush
              end
            end
          end

          # transmit stderr
          workers << NoisyThread.new do
            FD.poll(stderr, throttle: Bash.configuration.throttle) do
              buffer = stderr.read_nonblock(BLOCK_SIZE)

              script.stderr << buffer

              if verbose
                STDERR.write buffer
                STDERR.flush
              end
            end
          end

          # accept & respond to prompts
          workers << NoisyThread.new do
            FD.poll(b2r, throttle: 0) do
              respond_to_prompts(r2b, b2r, bus_file, script)
            end
          end

          # wait for the script to finish executing
          wait_thr.join

          # clean up
          try_hard "close r2b" do r2b.close end
          try_hard "close b2r" do b2r.close end
          try_hard "shut off workers" do workers.map(&:join) end
          try_hard "kill them all" do workers.map(&:kill) end
          try_hard "clean up temp bus file" do bus_file.unlink end
          try_hard "clean up source file" do file.unlink end

          script.track_exit_code wait_thr.value.exitstatus

          wait_thr.value.success?
        end
      end

      private

      def respond_to_prompts(fd_in, fd_out, bus_file, script)
        fd_out.expect(MESSAGE_REQ, 1) do |result|
          break if result.nil?

          lines = result[0].split("\n").reject(&:empty?)

          stubs = lines.each_with_index.reduce([]) do |acc, (line, index)|
            next acc unless line == MESSAGE_REQ

            message = lines[index-1]
            frames, err = MessageDecoder.decode(message)

            if err
              STDERR.puts <<-EOF
                bash-rspec: communication between Ruby and Bash failed, this is
                most likely an internal error.

                #{err}
              EOF

              next acc
            end

            stub = frames.reduce({ expr: nil, type: nil, args: [], stacktrace: [] }) do |x, (type, content)|
              case type
              when FRAME_NAME
                x[:expr] = content
                x[:type] = content == CONDITIONAL_EXPR_STUB ? :conditional : :function
              when FRAME_ARG
                x[:args] << content
              when FRAME_TRACE
                x[:stacktrace] << content unless content.empty?
              else
                STDERR.puts "rspec-bash: unrecognized frame '#{type}' => '#{content}'"
                STDERR.puts "rspec-bash: source:\n#{message}"
              end

              x
            end.tap do |stub|
              stub[:args] = stub[:args].join(' ')
            end

            acc.push(stub)
          end

          stubs.each do |stub|
            case stub[:type]
            when :conditional
              relay_conditional_stub(fd_in, fd_out, bus_file, script: script, stub: stub)
            when :function
              relay_command_stub(fd_in, fd_out, bus_file, script: script, stub: stub)
            when :unknown
              STDERR.puts "[err] unexpected message from bash: #{stub.inspect}"
            end
          end
        end
      end

      def relay_command_stub(fd_in, fd_out, bus_file, script:, stub:)
        if !script.has_stub?(stub[:expr])
          fail(
            "#{stub[:expr]} is not stubbed!\n\n" +
            "Call stack:\n" +
            stub[:stacktrace].map { |x| "- #{x}" }.join("\n")
          )
        end

        File.write(bus_file, script.stubbed(stub[:expr], stub[:args]))

        fd_in.puts bus_file.path
        fd_in.flush

        fd_out.expect(MESSAGE_ACK, 1)

        script.track_call(stub[:expr], stub[:args])
      end

      def relay_conditional_stub(fd_in, fd_out, bus_file, script:, stub:)
        if !script.has_conditional_stubs? && !Bash.configuration.allow_unstubbed_conditionals
          fail "conditional expressions are not stubbed!\n#{stub[:stacktrace]}"
        end

        File.write(bus_file, script.stubbed_conditional(stub[:args]))

        fd_in.puts bus_file.path
        fd_in.flush

        fd_out.expect(MESSAGE_ACK, 1)

        script.track_conditional_call(stub[:args])
      end

      def try_hard(what)
        begin
          yield
        rescue StandardError => e
          puts what
          puts e
          puts e.backtrace
        end
      end
    end
  end
end