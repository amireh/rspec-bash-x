require 'open3'
require 'expect'
require 'tempfile'

module BashIt
  class ShellScriptEvaluator
    class NoisyThread < Thread
      def initialize(**)
        super.tap do
          self.abort_on_exception = true
        end
      end
    end

    module FD
      def self.readable?(fd)
        begin
          !fd.closed? && !fd.eof?
        rescue IOError => e
          if e.to_s == "stream closed"
            return false
          else
            throw
          end
        end
      end

      def self.poll(fd, &block)
        while readable?(fd) do
          begin
            yield fd
            sleep 0.1
          rescue IO::WaitReadable
            IO.select([ fd ])
            retry
          rescue IOError => e
            STDERR.puts "[err] unexpected IOError #{e}"
            break
          rescue EOFError
            break
          end
        end
      end
    end

    def eval(script)
      file = Tempfile.new('bash_it')
      file.write(script.to_s)
      file.close

      self.class.popenX('/usr/bin/env', 'bash', file.path) do |input, output, error, r2b, b2r, wait_thr|
        workers = [
          NoisyThread.new do
            FD.poll(output) do
              STDOUT.write output.read_nonblock(4096)
            end
          end,

          NoisyThread.new do
            FD.poll(error) do
              STDERR.write error.read_nonblock(4096)
            end
          end,

          NoisyThread.new do
            FD.poll(b2r) do
              respond_to_prompts(r2b, b2r, script)
            end
          end,
        ]

        wait_thr.join

        try_hard "close r2b" do r2b.close end
        try_hard "close b2r" do b2r.close end
        try_hard "shut off workers" do workers.map(&:join) end
        try_hard "kill them all" do workers.map(&:kill) end
      end
    end

    private

    def self.popenX(*cmd, **opts, &block)
      in_r, in_w = IO.pipe
      opts[:in] = in_r

      out_r, out_w = IO.pipe
      opts[:out] = out_w

      err_r, err_w = IO.pipe
      opts[:err] = err_w

      b2r_r, b2r_w = IO.pipe
      r2b_r, r2b_w = IO.pipe

      opts[4] = r2b_r
      opts[5] = b2r_w

      Open3.send(:popen_run,
        cmd,
        opts,
        [in_r, out_w, err_w, r2b_r, b2r_w], # child_io
        [in_w, out_r, err_r, r2b_w, b2r_r], # parent_io
        &block
      )
    end

    def respond_to_prompts(fd_in, fd_out, script)
      fd_out.expect("stub>", 1) do |result|
        break if result.nil?

        prompts = result[0].split("\n").reject(&:empty?).reduce([]) do |acc, line|
          if line == "stub>"
            if acc[-1]
              acc[-1][:type] = :stub
            else
              puts "[WARN] cannot match stub entry: #{line} => #{acc}"
            end
          else
            acc.push({ type: :unknown, buffer: line })
          end

          acc
        end

        prompts.each do |type:, buffer:|
          case type
          when :stub
            routine_len = buffer.index(' ')
            routine = buffer[0..routine_len - 1]
            args    = buffer[routine_len + 1..-1]

            fd_in.puts script.stubbed(routine, args)
            fd_in.flush

            fd_out.expect('stub-body>', 1)
          when :unknown
            STDERR.write "[err] unexpected message from bash: #{buffer}"
          end
        end
      end
    end

    def try_hard(what)
      begin
        yield
      rescue StandardError => e
        puts what
        puts e
      end
    end
  end
end