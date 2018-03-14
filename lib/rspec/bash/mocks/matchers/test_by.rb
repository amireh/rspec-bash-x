require_relative '../doubles'
require_relative './base_matcher'

module RSpec
  module Bash
    module Mocks
      module Matchers
        # @private
        class TestBy < BaseMatcher
          def initialize(expr)
            @double = Doubles::ConditionalDouble.new(expr)
            @display_name = "test_by"

            super()
          end

          def with_args(args)
            tap {
              fullexpr = "#{@double.expr} #{args}"

              @double.expected_calls << fullexpr
              @double.behaviors << create_behavior(args: fullexpr)
            }
          end
        end
      end
    end
  end
end