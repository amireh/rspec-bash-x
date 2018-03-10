require 'rspec/support'
require 'rspec/support/caller_filter'
require 'rspec/mocks'
require 'rspec/mocks/proxy'

require_relative './shell_script_message_expectation'

module BashIt
  module RSpec
    class ShellScriptProxy < ::RSpec::Mocks::Proxy
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

        @expectations << ShellScriptMessageExpectation.new(
          spec,
          @error_generator,
          location
        )
      end
    end
  end
end

module RSpec
  module Mocks
    class Space
      alias __bashit_proxy_for proxy_for

      def proxy_for(object)
        return __bashit_proxy_for(object) unless object.is_a?(BashIt::ShellScript)

        proxy_mutex.synchronize do
          id = id_for(object)
          proxies.fetch(id) do
            proxies[id] = BashIt::RSpec::ShellScriptProxy.new(object, @expectation_ordering)
          end
        end
      end
    end
  end
end
