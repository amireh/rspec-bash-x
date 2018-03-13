require_relative '../doubles'
require_relative './base_matcher'

module BashIt
  module RSpec
    module Matchers
      # @private
      class Receive < BaseMatcher
        def initialize(routine)
          @double = Doubles::FunctionDouble.new(routine)
          @display_name = "receive"

          super()
        end
      end
    end
  end
end
