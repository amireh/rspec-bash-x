module RSpec
  module Bash
    module Mocks
      module Doubles
        class FunctionDouble < AbstractDouble
          def initialize(routine)
            super()

            @routine = routine
          end

          def apply(script)
            script.stub(@routine, call_original: call_original, subshell: subshell, &body)
          end

          def call_count(script)
            script.calls_for(@routine).count
          end

          def call_args(script)
            script.calls_for(@routine).map { |x| x[:args] }
          end

          def to_s
            @routine.to_s
          end
        end
      end
    end
  end
end