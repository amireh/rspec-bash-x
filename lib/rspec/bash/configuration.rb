module RSpec
  module Bash
    class Configuration
      attr_accessor :throttle
      attr_accessor :read_fd
      attr_accessor :write_fd

      def initialize()
        @throttle = 25 / 1000.0
        @read_fd = 62
        @write_fd = 63
      end
    end
  end
end