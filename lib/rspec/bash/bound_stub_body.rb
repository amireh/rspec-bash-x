module RSpec
  module Bash
    class BoundStubBody
      def initialize(args, &block)
        @args = args
        @block = block
      end

      def applicable?(call_args)
        @args == call_args
      end

      def call(*args)
        @block.call(*args)
      end
    end
  end
end