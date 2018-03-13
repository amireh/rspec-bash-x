require 'rspec/mocks/space'

module BashIt
  module RSpec
    module Matchers
      # @private
      class BaseMatcher
        attr_reader :double

        def initialize()
          fail "@double must be created by implementation" if @double.nil?
          fail "@display_name must be specified by implementation" if @display_name.nil?
        end

        def name
          @display_name
        end

        def description
          @describable.description_for(name)
        end

        def with_args(args)
          tap { @double.expected_calls << args }
        end

        def and_return(code)
          tap { @double.body = lambda { |*| "return #{code}" } }
        end

        def and_yield(&block)
          tap { @double.body = block }
        end

        def exactly(n)
          tap { @double.expected_call_count = [:exactly, n] }
        end

        def at_least(n)
          tap { @double.expected_call_count = [:at_least, n] }
        end

        def at_most(n)
          tap { @double.expected_call_count = [:at_most, n] }
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
          proxy.__send__(method, @double, @display_name, &block) # => ScriptMessageExpectation
        end
      end
    end
  end
end
