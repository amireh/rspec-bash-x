module RSpec
  module Bash
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

      def self.poll(fd, throttle: 25 / 1000, &block)
        while readable?(fd) do
          begin
            yield fd
            sleep throttle if throttle > 0
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
  end
end