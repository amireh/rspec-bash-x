require 'rspec/mocks'
require 'rspec/mocks/matchers/expectation_customization'

module BashIt
  module RSpec
    module Matchers
      def receive_shell(*args)
        ReceiveShell.new(*args)
      end

      # @private
      class ReceiveShell
        def initialize(routine)
          @spec = {
            body: nil,
            call_count: [:at_least, 1],
            routine: routine,
          }
        end

        def name
          "receive_shell"
        end

        def description
          @describable.description_for("receive_shell")
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
          proxy.__send__(method, @spec, &block) # => ShellScriptMessageExpectation
        end
      end
    end
  end
end
