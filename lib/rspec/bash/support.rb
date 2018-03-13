module RSpec
  module Bash
    module Support
      def run_script(script, **opts)
        ScriptEvaluator.new.eval(script, opts)
      end
    end
  end
end