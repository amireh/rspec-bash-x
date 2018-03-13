require_relative './matchers/receive'
require_relative './matchers/test'

module BashIt
  module RSpec
    module Matchers
      def receive(*args)
        Receive.new(*args)
      end

      def test(*args)
        Test.new(*args)
      end
    end
  end
end
