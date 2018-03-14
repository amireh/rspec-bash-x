module RSpec
  module Bash
    module Mocks
      module Doubles
        class ExactConditionalDouble < AbstractDouble
          attr_accessor :fullexpr

          def initialize(fullexpr)
            super()

            @fullexpr = fullexpr
          end

          def apply(script)
            script.stub_conditional(@fullexpr,
              behaviors: behaviors
            )
          end

          def call_count(script)
            script.exact_conditional_calls_for(@fullexpr).count
          end

          def call_args(script)
            script.exact_conditional_calls_for(@fullexpr)
          end

          def to_s
            @fullexpr.to_s
          end
        end
      end
    end
  end
end