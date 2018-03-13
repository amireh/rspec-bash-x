require 'rspec/mocks'
require 'rspec/mocks/space'

require_relative '../../lib/rspec/bash/mocks/script_proxy'
require_relative '../../lib/rspec/bash/script'

module RSpec
  module Mocks
    class Space
      alias __rspec_bash_proxy_for proxy_for

      def proxy_for(object)
        return __rspec_bash_proxy_for(object) unless object.is_a?(RSpec::Bash::Script)

        proxy_mutex.synchronize do
          id = id_for(object)
          proxies.fetch(id) do
            proxies[id] = RSpec::Bash::Mocks::ScriptProxy.new(object, @expectation_ordering)
          end
        end
      end
    end
  end
end
