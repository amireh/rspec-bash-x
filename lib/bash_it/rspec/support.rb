module BashIt
  module RSpec
    module Support
      def run_script(script)
        ScriptEvaluator.new.eval(script)
      end
    end
  end
end