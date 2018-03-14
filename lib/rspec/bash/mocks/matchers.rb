require_relative './matchers/receive'
require_relative './matchers/test_for'
require_relative './matchers/test_by'

module RSpec
  module Bash
    module Mocks
      module Matchers
        def receive(*args)
          Receive.new(*args)
        end

        def receive_function(method_name, &block)
          ::RSpec::Mocks::Matchers::Receive.new(method_name, block)
        end

        def test_for(*args)
          TestFor.new(*args)
        end

        def test_by(*args)
          TestBy.new(*args)
        end
      end
    end
  end
end