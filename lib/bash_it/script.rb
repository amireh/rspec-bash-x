require 'tempfile'

module BashIt
  class Script
    MAIN_SCRIPT_FILE = File.expand_path('../../bashit.sh', __FILE__)
    NOOP = lambda { |*| '' }

    def self.load(path)
      new(File.read(path))
    end

    attr_reader :source, :source_file

    def initialize(source, path = '<<memory>>')
      @conditional_stubs = []
      @conditional_stub_calls = []
      @source = source
      @source_file = path
      @stubs = {}
      @stub_calls = Hash.new { |h, k| h[k] = [] }
    end

    def to_s
      to_bash_script
    end

    def inspect
      "Script(\"#{File.basename(@source_file)}\")"
    end

    def stub(fn, &body)
      @stubs[fn.to_sym] = body || NOOP
    end

    def stub_conditional(expr, &body)
      @conditional_stubs << { expr: expr, body: body || NOOP }
    end

    def stubbed(name, args)
      fail "#{name} is not stubbed" unless @stubs.key?(name.to_sym)

      @stubs[name.to_sym][args]
    end

    def stubbed_conditional(expr, args)
      ensure_conditionals_are_stubbed!

      conditional_stub = @conditional_stubs.detect { |x| x[:expr] == expr }

      if conditional_stub
        conditional_stub[:body][args]
      else
        ""
      end
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
      ensure_conditionals_are_stubbed!

      @conditional_stub_calls.push({ expr: expr, args: args })
    end

    private

    def to_bash_script
      ". '#{Script::MAIN_SCRIPT_FILE}'" + "\n" +
      @stubs.keys.map do |name|
        "#{name}()(__bashit_run_stub '#{name}' $@)"
      end.join("\n") + "\n" +
      @source
    end

    def ensure_conditionals_are_stubbed!
      fail "conditional expressions are not stubbed!" unless @conditional_stubs.any?
    end
  end
end