module RSpec
  module Bash
    class MessageDecoder
      READING_FRAME = 2
      READING_FRAME_SZ = 1
      RE_NUMBER = /\d/

      def self.decode(buffer)
        state = READING_FRAME_SZ
        frames = []
        frame = ''
        framesz = ''
        frameread = 0
        cursor = 0

        while cursor < buffer.length
          char = buffer[cursor]
          cursor += 1

          case state
          when READING_FRAME_SZ
            case char
            when ';'
              state = READING_FRAME
              frame = ''
              framesz = framesz.to_i
              frameread = 0
            else
              framesz += char
            end
          when READING_FRAME
            frameread += 1
            frame += char

            if frameread == framesz
              state = READING_FRAME_SZ
              frames.push(frame)
              framesz = ''
            end
          end
        end

        frames.map do |frame|
          frame_class, frame_content = frame[0], frame.slice(2..-1)
        end
      end
    end
  end
end