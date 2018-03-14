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
      CONDITIONAL_EXPR_STUB = 'conditional_expr'.freeze
      BLOCK_SIZE = 4096

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
            FD.poll(b2r, throttle: Bash.configuration.throttle) do
              respond_to_prompts(r2b, b2r, script, bus_file)
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

      def respond_to_prompts(fd_in, fd_out, script, bus_file)
        fd_out.expect("</rspec_bash::stub>", 1) do |result|
          break if result.nil?

          lines = result[0].split("\n").reject(&:empty?)

          stubs = lines.each_with_index.reduce([]) do |acc, (line, index)|
            next acc unless line == "</rspec_bash::stub>"

            message = lines[index-1]
            frames = MessageDecoder.decode(message)

            stub = frames.reduce({ expr: nil, type: nil, args: [], stacktrace: [] }) do |x, (type, content)|
              case type
              when 'n'
                x[:expr] = content
                x[:type] = content == CONDITIONAL_EXPR_STUB ? :conditional : :function
              when 'a'
                x[:args] << content
              when 'f'
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
              if !script.has_conditional_stubs? && !Bash.configuration.allow_unstubbed_conditionals
                fail "conditional expressions are not stubbed!\n#{stub[:stacktrace]}"
              end

              File.write(bus_file, script.stubbed_conditional(stub[:args]))

              fd_in.puts bus_file.path
              fd_in.flush

              fd_out.expect('</rspec_bash::stub-body>', 1)

              script.track_conditional_call(stub[:args])
            when :function
              if !script.has_stub?(stub[:expr])
                fail(
                  "#{stub[:expr]} is not stubbed!\n\n" +
                  "Call stack:\n" +
                  stub[:stacktrace].map { |x| "- #{x}" }.join("\n")
                )
              end

              routine = stub[:expr]
              args    = stub[:args]
              body    = script.stubbed(routine, args)

              File.write(bus_file, body)

              fd_in.puts bus_file.path
              fd_in.flush

              fd_out.expect('</rspec_bash::stub-body>', 1)

              script.track_call(routine, args)
            when :unknown
              STDERR.write "[err] unexpected message from bash: #{stub.inspect}"
            end
          end
        end
      end

      def split_by_first_space(string)
        delim = string.index(' ')

        # single-argument expressions, this usually happens in unary tests
        # where the argument evaluates to an empty string, a la:
        #
        #     test -z "${string}" => "-z"
        if delim.nil?
          return [ string, '' ]
        end

        [ string[0..delim - 1], string[delim + 1..-1] ]
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

      def remove_space_guards(string)
        string.gsub(/^[ ]{1}|[ ]$/, '')
      end
    end
  end
end