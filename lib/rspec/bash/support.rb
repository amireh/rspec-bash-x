module RSpec
  module Bash
    module Support
      def run_script(script, args = [], **opts)
        ScriptEvaluator.new.eval(script, args, opts)
      end
    end
  end
end