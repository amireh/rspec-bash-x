module RSpec
  module Bash
    module FD
      def self.readable?(fd)
        begin
          !fd.closed? && !fd.eof?
        rescue IOError => e
          if noise? e
            return false
          else
            throw e
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
            if noise? e
              break
            else
              throw e
            end
          rescue EOFError
            break
          end
        end
      end

      def self.noise?(error)
        error.to_s == "stream closed" || error.to_s == "closed stream"
      end
    end
  end
end