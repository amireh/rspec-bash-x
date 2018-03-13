require_relative '../doubles'
require_relative './base_matcher'

module BashIt
  module RSpec
    module Matchers
      # @private
      class Test < BaseMatcher
        def initialize(expr)
          @double = Doubles::ConditionalDouble.new(expr)
          @display_name = "test(#{expr})"

          super()
        end
      end
    end
  end
end
