require_relative './stub_behavior'
require_relative './script_generator'

module RSpec
  module Bash
    class Script
      MAIN_SCRIPT_FILE = File.expand_path('../controller.sh', __FILE__)
      NOOP = lambda { |*| '' }
      NOOP_BEHAVIOR = StubBehavior.new(body: NOOP, charges: Float::INFINITY)

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
        ScriptGenerator.generate(self)
      end

      def inspect
        "Script(\"#{File.basename(@source_file)}\")"
      end

      def stub(fn, behaviors:, call_original: false, subshell: true)
        @stubs[fn.to_sym] = {
          behaviors: behaviors.map { |x| StubBehavior.new(x) },
          subshell: subshell,
          call_original: call_original
        }
      end

      def stub_conditional(expr, behaviors:)
        @conditional_stubs << {
          behaviors: behaviors.map { |x| StubBehavior.new(x) },
          expr: expr,
        }
      end

      def stubbed(name, args)
        apply_matching_behavior @stubs[name.to_sym], args
      end

      def stubbed_conditional(fullexpr)
        conditional_stub = @conditional_stubs.detect { |x| fullexpr.index(x[:expr]) == 0 }

        if conditional_stub
          apply_matching_behavior conditional_stub, fullexpr
        else
          ""
        end
      end

      def has_stub?(name)
        @stubs.key?(name.to_sym)
      end

      def has_conditional_stubs?
        @conditional_stubs.any?
      end

      def calls_for(name)
        @stub_calls[name.to_sym]
      end

      def conditional_calls_for(expr)
        @conditional_stub_calls.select { |x| x.index(expr) == 0 }
      end

      def exact_conditional_calls_for(fullexpr)
        @conditional_stub_calls.select { |x| x == fullexpr }
      end

      def track_call(name, args)
        fail "#{name} is not stubbed" unless @stubs.key?(name.to_sym)

        @stub_calls[name.to_sym].push({ args: args })
      end

      def track_conditional_call(fullexpr)
        @conditional_stub_calls.push(fullexpr)
      end

      def track_exit_code(code)
        @exit_code = code
      end

      private

      def apply_matching_behavior(stub, args)
        behavior = stub[:behaviors].detect { |x| x.usable? && x.applicable?(args) }
        behavior ||= stub[:behaviors].detect { |x| x.usable? && x.context_free? }
        behavior ||= NOOP_BEHAVIOR
        behavior.apply!(args)
      end
    end
  end
end