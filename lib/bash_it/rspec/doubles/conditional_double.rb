module BashIt
  module RSpec
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
      end
    end
  end
end
