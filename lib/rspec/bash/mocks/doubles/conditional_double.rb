module RSpec
  module Bash
    module Mocks
      module Doubles
        class ConditionalDouble < AbstractDouble
          attr_accessor :expr

          def initialize(expr)
            super()

            @expr = expr
          end

          def apply(script)
            script.stub_conditional(@expr,
              behaviors: behaviors
            )
          end

          def call_count(script)
            script.conditional_calls_for(@expr).count
          end

          def call_args(script)
            script.conditional_calls_for(@expr)
          end

          def to_s
            @expr.to_s
          end
        end
      end
    end
  end
end