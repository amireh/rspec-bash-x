require 'rspec/support'
require 'rspec/support/caller_filter'
require 'rspec/mocks'
require 'rspec/mocks/proxy'

require_relative './script_message_expectation'

module BashIt
  module RSpec
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

      def add_message_expectation(double, display_name, opts=DEFAULT_MESSAGE_EXPECTATION_OPTS, &block)
        location = opts.fetch(:expected_from) { ::RSpec::CallerFilter.first_non_rspec_line }

        double.apply(object)

        @expectations << ScriptMessageExpectation.new(
          double,
          display_name,
          @error_generator,
          location
        )
      end
    end
  end
end
