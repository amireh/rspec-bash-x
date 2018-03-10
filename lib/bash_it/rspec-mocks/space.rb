require 'rspec/mocks'
require 'rspec/mocks/space'

require_relative '../rspec/shell_script_proxy'
require_relative '../shell_script'

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
