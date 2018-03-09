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
        function __bashit_to_ruby() {
          echo 1>&5 $@
        }

        function __bashit_from_ruby() {
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

    def self.popenX(*cmd, **opts, &block)
      in_r, in_w = IO.pipe
      opts[:in] = in_r
      in_w.sync = true

      out_r, out_w = IO.pipe
      opts[:out] = out_w

      err_r, err_w = IO.pipe
      opts[:err] = err_w

      b2r_r, b2r_w = IO.pipe
      r2b_r, r2b_w = IO.pipe
      r2b_w.sync = true
      opts[4] = r2b_r
      opts[5] = b2r_w

      Open3.send(:popen_run,
        cmd,
        opts,
        [in_r, out_w, err_w, r2b_r, b2r_w], # child_io
        [in_w, out_r, err_r, r2b_w, b2r_r], # parent_io
        &block
      )
    end

    private

    def create_stub(stub)
      """
        __original_#{stub[:name]}__=#{stub[:name]}
        __body=""

        function #{stub[:name]}() {
          echo \"test\"
          __bashit_to_ruby \"#{stub[:name]} $@\"
          __bashit_to_ruby \"stub>\"

          local __body

          __bashit_from_ruby  __body
          __bashit_to_ruby    \"stub-body>\"

          # track_call \"#{stub[:name]}\" $@
          # #{stub[:body].call}

          $__body
        }
      """
    end
  end

end