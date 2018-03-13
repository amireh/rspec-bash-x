require 'rspec/mocks/space'

module BashIt
  module RSpec
    module Matchers
      # @private
      class BaseMatcher
        include ::RSpec::Mocks::Matchers::Matcher

        attr_reader :double

        def initialize()
          fail "@double must be created by implementation" if @double.nil?
          fail "@display_name must be specified by implementation" if @display_name.nil?
        end

        def name
          @display_name
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
        #
        # (BashIt::Script): ScriptMessageExpectation
        def matches?(subject, &block)
          proxy_for(subject).expect_message(
            double: @double,
            display_name: @display_name
          )
        end

        # @private
        #
        # (BashIt::Script): ScriptMessageExpectation
        def setup_allowance(subject, &block)
          proxy_for(subject).allow_message(
            double: @double
          )
        end

        private

        def proxy_for(subject)
          ::RSpec::Mocks.space.proxy_for(subject)
        end
      end
    end
  end
end
