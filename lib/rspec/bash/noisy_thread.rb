module RSpec
  module Bash
    class NoisyThread < Thread
      def initialize(**)
        super.tap do
          self.abort_on_exception = true
        end
      end
    end
  end
end