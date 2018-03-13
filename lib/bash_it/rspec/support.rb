module BashIt
  module RSpec
    module Support
      def run_script(script, **opts)
        ScriptEvaluator.new.eval(script, opts)
      end
    end
  end
end