require 'tempfile'

module BashIt
  class Script
    MAIN_SCRIPT_FILE = File.expand_path('../../bashit.sh', __FILE__)

    def self.load(path)
      new(File.read(path))
    end

    attr_reader :source, :source_file

    def initialize(source, path = '<<memory>>')
      @source = source
      @source_file = path
      @stubs = {}
      @stub_calls = Hash.new { |h, k| h[k] = [] }
    end

    def stub(fn, &body)
      @stubs[fn.to_sym] = body || lambda { |*| '' }
    end

    def to_s
      ". '#{Script::MAIN_SCRIPT_FILE}'" + "\n" +
      @stubs.keys.map do |name|
        "function #{name}()(__bashit_run_stub '#{name}' $@)"
      end.join("\n") + "\n" +
      @source
    end

    def inspect
      "Script(\"#{File.basename(@source_file)}\")"
    end

    def calls_for(name)
      @stub_calls[name.to_sym]
    end

    def stubbed(name, args)
      fail "#{name} is not stubbed" unless @stubs.key?(name.to_sym)

      @stubs[name.to_sym][args]
    end

    def track_call(name, args)
      fail "#{name} is not stubbed" unless @stubs.key?(name.to_sym)

      @stub_calls[name.to_sym].push(args)
    end
  end
end