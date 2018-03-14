require 'rspec/support'
require 'rspec/support/caller_filter'
require 'rspec/mocks'
require 'rspec/mocks/proxy'

require_relative './script_message_expectation'

module RSpec
  module Bash
    module Mocks
      class ScriptProxy < ::RSpec::Mocks::Proxy
        def initialize(*)
          @expectations = []
          super
        end

        def reset
          @expectations.clear
          super
        end

        def verify
          @expectations.each do |expectation|
            expectation.verify_messages_received(@object)
          end
        end

        def expect_message(double:, display_name:)
          allow_message(double: double)

          ScriptMessageExpectation.new(
            double: double,
            display_name: display_name,
            error_generator: @error_generator,
            backtrace_line: ::RSpec::CallerFilter.first_non_rspec_line
          ).tap { |x| @expectations << x }
        end

        def allow_message(double:)
          double.apply(object)
        end
      end
    end
  end
end