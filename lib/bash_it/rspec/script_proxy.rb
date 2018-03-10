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

      def add_message_expectation(spec, opts=DEFAULT_MESSAGE_EXPECTATION_OPTS, &block)
        location = opts.fetch(:expected_from) { ::RSpec::CallerFilter.first_non_rspec_line }

        object.stub(spec[:routine], &spec[:body])

        @expectations << ScriptMessageExpectation.new(
          spec,
          @error_generator,
          location
        )
      end
    end
  end
end
