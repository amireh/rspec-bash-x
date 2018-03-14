require_relative '../doubles'
require_relative './base_matcher'

module RSpec
  module Bash
    module Mocks
      module Matchers
        # @private
        class TestFor < BaseMatcher
          def initialize(fullexpr)
            @double = Doubles::ExactConditionalDouble.new(fullexpr)
            @display_name = "test_for"

            super()
          end

          def with_args(args)
            fail "#{to_s}: cannot be used with '.with_args', use 'test_by' instead"
          end

          protected

          def create_behavior(**rest)
            super(**rest, args: @double.fullexpr)
          end
        end
      end
    end
  end
end