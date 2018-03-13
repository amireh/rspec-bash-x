module RSpec
  module Bash
    module Mocks
      module Doubles
        class ConditionalDouble < AbstractDouble
          def initialize(expr)
            super()

            @expr = expr
          end

          def apply(script)
            script.stub_conditional(@expr, &body)
          end

          def call_count(script)
            script.conditional_calls_for(@expr).count
          end

          def call_args(script)
            script.conditional_calls_for(@expr).map { |x| x[:args] }
          end

          def to_s
            @expr.to_s
          end
        end
      end
    end
  end
end