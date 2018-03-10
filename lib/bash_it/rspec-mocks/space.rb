require 'rspec/mocks'
require 'rspec/mocks/space'

require_relative '../rspec/script_proxy'
require_relative '../script'

module RSpec
  module Mocks
    class Space
      alias __bashit_proxy_for proxy_for

      def proxy_for(object)
        return __bashit_proxy_for(object) unless object.is_a?(BashIt::Script)

        proxy_mutex.synchronize do
          id = id_for(object)
          proxies.fetch(id) do
            proxies[id] = BashIt::RSpec::ScriptProxy.new(object, @expectation_ordering)
          end
        end
      end
    end
  end
end
