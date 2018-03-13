module RSpec
  module Bash
    class Configuration
      attr_accessor :allow_unstubbed_conditionals
      attr_accessor :read_fd
      attr_accessor :throttle
      attr_accessor :verbose
      attr_accessor :write_fd

      def initialize()
        @allow_unstubbed_conditionals = true
        @throttle = 25 / 1000.0
        @read_fd = 62
        @write_fd = 63
        @verbose = false
      end
    end
  end
end