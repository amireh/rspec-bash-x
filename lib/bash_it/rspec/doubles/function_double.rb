module BashIt
  module RSpec
    module Doubles
      class FunctionDouble < AbstractDouble
        def initialize(routine)
          super()

          @routine = routine
        end

        def apply(script)
          script.stub(@routine, &body)
        end

        def call_count(script)
          script.calls_for(@routine).count
        end

        def call_args(script)
          script.calls_for(@routine).map { |x| x[:args] }
        end
      end
    end
  end
end
