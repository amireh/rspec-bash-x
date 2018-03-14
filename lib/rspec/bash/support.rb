module RSpec
  module Bash
    module Support
      def a_script(*args)
        Script.new(*args)
      end

      def run_script(script, args = [], **opts)
        ScriptEvaluator.new.eval(script, args, opts)
      end
    end
  end
end