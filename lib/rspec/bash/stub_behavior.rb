module RSpec
  module Bash
    class StubBehavior
      attr_accessor :args, :body

      def initialize(args: nil, body:, charges: 1, subshell: true)
        @args = args
        @body = body
        @subshell = subshell
        @charges = charges
      end

      def usable?
        @charges > 0
      end

      def applicable?(args)
        @args == args
      end

      def context_free?
        @args.nil?
      end

      def requires_subshell?
        @subshell
      end

      def apply!(args)
        @charges -= 1
        @body.call(args)
      end
    end
  end
end