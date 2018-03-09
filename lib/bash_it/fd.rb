module BashIt
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

    def self.poll(fd, throttle: 0.1, &block)
      while readable?(fd) do
        begin
          yield fd
          sleep throttle
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