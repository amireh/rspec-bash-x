module BashIt
  class ShellScript
    def initialize(path)
      @source = File.read(path)
      @stubs = []
    end

    def stub(fn, &body)
      @stubs << {
        calls: [],
        name: fn.to_sym,
        body: body || lambda { '' },
      }
    end

    def to_s()
      """
        declare -a calls=()
        function __bashit_write() {
          echo 1>&5 $@
        }

        function __bashit_read() {
          read -u 4 $@
        }

        __bashit_echo=echo

        function track_call() {
          calls+=($@)
        }

        #{@stubs.map do |stub|
          create_stub(stub)
        end.join("\n")}
      """.strip + "\n" + @source
    end

    def eval
      `#{to_s}`
    end

    def calls_for(name)
    end

    def stubbed(name)
      @stubs.detect { |x| x[:name] == name.to_sym }[:body][]
    end

    private

    def create_stub(stub)
      """
        __original_#{stub[:name]}__=#{stub[:name]}
        __body=""

        function #{stub[:name]}() {
          echo \"test\"
          __bashit_write \"#{stub[:name]} $@\"
          __bashit_write \"stub>\"

          local __body

          __bashit_read  __body
          __bashit_write \"stub-body>\"

          # track_call \"#{stub[:name]}\" $@
          # #{stub[:body].call}

          $__body
        }
      """
    end
  end

end