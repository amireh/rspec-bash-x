module RSpec
  module Bash
    module Mocks
      module Doubles
        class AbstractDouble
          attr_accessor :body, :call_original, :calls, :expected_call_count, :expected_calls

          def initialize(*)
            @body = nil
            @call_original = false
            @calls = []
            @expected_call_count = [:at_least, 1]
            @expected_calls = []
          end

          def apply
            fail "NotImplemented"
          end

          def call_count
            fail "NotImplemented"
          end
        end
      end
    end
  end
end