module BashIt
  class ShellScript
    def initialize(path)
      @source = File.read(path)
      @stubs = {}
      @stub_calls = {}
    end

    def stub(fn, &body)
      @stubs[fn.to_sym] = body || lambda { '' }
      @stub_calls = {}
    end

    def to_s()
      """
        # bashit
        # ---------------------------------------------------------------------
        function __bashit_write() {
          builtin echo 1>&5 $@
        }

        function __bashit_read() {
          builtin read -u 4 $@
        }

        # bashit: stubs
        # ---------------------------------------------------------------------
        #{@stubs.keys.map(&method(:define_stub)).join("\n")}
        # ---------------------------------------------------------------------
      """.strip + "\n" + @source
    end

    def eval
      `#{to_s}`
    end

    def calls_for(name)
    end

    def stubbed(name, args)
      unless @stubs.key?(name.to_sym)
        fail "#{name} is not stubbed"
      end

      @stubs[name.to_sym][args]
    end

    private

    def define_stub(name)
      """
        function #{name}() {
          __bashit_write \"#{name} $@\"
          __bashit_write \"stub>\"

          local __body

          __bashit_read  __body
          __bashit_write \"stub-body>\"

          $__body
        }
      """
    end
  end

end