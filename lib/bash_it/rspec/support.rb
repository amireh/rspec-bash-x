module BashIt
  module RSpec
    module Support
      def run_script(script)
        ShellScriptEvaluator.new.eval(script)
      end
    end
  end
end