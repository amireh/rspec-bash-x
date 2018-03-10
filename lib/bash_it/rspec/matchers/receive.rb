require 'rspec/mocks'
require 'rspec/mocks/matchers/expectation_customization'

module BashIt
  module RSpec
    module Matchers
      def receive(*args)
        Receive.new(*args)
      end

      # @private
      class Receive
        def initialize(routine)
          @spec = {
            body: nil,
            call_count: [:at_least, 1],
            routine: routine,
          }
        end

        def name
          "receive"
        end

        def description
          @describable.description_for(name)
        end

        def and_return(code)
          tap { @spec[:body] = lambda { |*| "return #{code}" } }
        end

        def and_yield(&block)
          tap { @spec[:body] = block }
        end

        def exactly(n)
          tap { @spec[:call_count] = [:exactly, n] }
        end

        def at_least(n)
          tap { @spec[:call_count] = [:at_least, n] }
        end

        def at_most(n)
          tap { @spec[:call_count] = [:at_most, n] }
        end

        def never
          exactly(0)
        end

        def once
          exactly(1)
        end

        def twice
          exactly(2)
        end

        def thrice
          exactly(3)
        end

        def times
          self
        end

        # @private
        def matches?(subject, &block)
          @describable = setup_mock_proxy_method_substitute(subject, :add_message_expectation, block)
        end

        # @private
        def setup_allowance(subject, &block)
          setup_mock_proxy_method_substitute(subject, :add_stub, block)
        end

        private

        def setup_mock_proxy_method_substitute(subject, method, block)
          proxy = ::RSpec::Mocks.space.proxy_for(subject)
          proxy.__send__(method, @spec, &block) # => ScriptMessageExpectation
        end
      end
    end
  end
end