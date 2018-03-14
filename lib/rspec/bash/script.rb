module RSpec
  module Bash
    class Script
      MAIN_SCRIPT_FILE = File.expand_path('../controller.sh', __FILE__)
      NOOP = lambda { |*| '' }

      def self.load(path)
        new(File.read(path))
      end

      attr_reader :exit_code, :source, :source_file, :stdout, :stderr, :stubs

      def initialize(source, path = 'Anonymous')
        @conditional_stubs = []
        @conditional_stub_calls = []
        @source = source
        @source_file = path
        @stubs = {}
        @stub_calls = Hash.new { |h, k| h[k] = [] }
        @stdout = ""
        @stderr = ""
        @exit_code = nil
      end

      def to_s
        BashScriptGenerator.generate(self)
      end

      def inspect
        "Script(\"#{File.basename(@source_file)}\")"
      end

      def stub(fn, call_original: false, subshell: true, &body)
        @stubs[fn.to_sym] = {
          body: (call_original || !body) ? NOOP : body,
          subshell: subshell,
          call_original: call_original
        }
      end

      def stub_conditional(expr, &body)
        @conditional_stubs << { expr: expr, body: body || NOOP }
      end

      def stubbed(name, args)
        fail "#{name} is not stubbed" unless @stubs.key?(name.to_sym)

        @stubs[name.to_sym][:body].call(args)
      end

      def stubbed_conditional(expr, args)
        conditional_stub = @conditional_stubs.detect { |x| x[:expr] == expr }

        if conditional_stub
          conditional_stub[:body].call(args)
        else
          ""
        end
      end

      def has_conditional_stubs?
        @conditional_stubs.any?
      end

      def calls_for(name)
        @stub_calls[name.to_sym]
      end

      def conditional_calls_for(expr)
        @conditional_stub_calls.select { |x| x[:expr] == expr }
      end

      def track_call(name, args)
        fail "#{name} is not stubbed" unless @stubs.key?(name.to_sym)

        @stub_calls[name.to_sym].push({ args: args })
      end

      def track_conditional_call(expr, args)
        @conditional_stub_calls.push({ expr: expr, args: args })
      end

      def track_exit_code(code)
        @exit_code = code
      end
    end
  end
end