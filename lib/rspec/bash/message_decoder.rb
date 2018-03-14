module RSpec
  module Bash
    class MessageDecoder
      READING_FRAME_COUNT = 1
      READING_FRAME_SZ = 2
      READING_FRAME = 3
      RE_NUMBER = /\d/

      def self.decode(buffer)
        state = READING_FRAME_COUNT
        buffersz = buffer.length
        frames = []
        frame_buf = ''
        frame_count_buf = ''
        frame_count = Float::INFINITY
        framesz_buf = ''
        framesz = Float::INFINITY
        cursor = 0

        while cursor < buffersz && frames.count < frame_count
          char = buffer[cursor]
          cursor += 1

          case state
          when READING_FRAME_COUNT
            case char
            when ';'
              state = READING_FRAME_SZ
              frame_count = frame_count_buf.to_i
              frame_count_buf = ''
              framesz_buf = ''
            when /\d/
              frame_count_buf += char
            else
              return nil, "invalid payload: illegal character in header '#{char}' (#{cursor}/#{buffersz})"
            end
          when READING_FRAME_SZ
            case char
            when ';'
              state = READING_FRAME
              frame_buf = ''
              framesz = framesz_buf.to_i
              framesz_buf = ''
            when /\d/
              framesz_buf += char
            else
              return nil, "invalid payload: illegal character in frame header '#{char}' (#{cursor}/#{buffersz})"
            end
          when READING_FRAME
            frame_buf += char

            if frame_buf.length == framesz
              state = READING_FRAME_SZ
              frames.push(frame_buf)
              framesz = Float::INFINITY
            end
          end
        end

        if frames.count != frame_count
          return nil, "invalid payload: expected #{frame_count} frames but got #{frames.count}"
        end

        [ frames.map do |frame|
          frame_class, frame_content = frame[0..1].to_i, frame.slice(2..-1)
        end ]
      end
    end
  end
end