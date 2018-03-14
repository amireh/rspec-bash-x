require_relative './bound_stub_body'

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

      def stub(fn, behaviors:, call_original: false, subshell: true, bodies: [])
        @stubs[fn.to_sym] = {
          behaviors: behaviors,
          bodies: call_original ? [ NOOP ] : bodies,
          subshell: subshell,
          call_original: call_original
        }
      end

      def stub_conditional(expr, bodies:, behaviors:)
        @conditional_stubs << {
          behaviors: behaviors,
          expr: expr,
          bodies: bodies
        }
      end

      def stubbed(name, args)
        # call_body_with_args @stubs[name.to_sym][:bodies], args
        apply_matching_behavior @stubs[name.to_sym][:behaviors], args
      end

      def stubbed_conditional(expr, args)
        conditional_stub = @conditional_stubs.detect { |x| x[:expr] == expr }

        if conditional_stub
          apply_matching_behavior conditional_stub[:behaviors], args
          # call_body_with_args(conditional_stub[:bodies], args)
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

      private

      def call_body_with_args(bodies, args)
        bound_body = bodies.detect { |x| x.is_a?(BoundStubBody) && x.applicable?(args) }

        return bound_body.call(args) if bound_body

        body = bodies.detect { |x| !x.is_a?(BoundStubBody) }

        return body.call(args) if body

        NOOP.call(args)
      end

      def apply_matching_behavior(behaviors, args)
        behavior = behaviors.detect { |x| !x[:args].nil? && x[:args] == args && x[:body] }

        return behavior[:body].call(args) if behavior

        behavior = behaviors.detect { |x| x[:args].nil? && x[:body] }

        return behavior[:body].call(args) if behavior

        NOOP.call(args)
      end
    end
  end
end