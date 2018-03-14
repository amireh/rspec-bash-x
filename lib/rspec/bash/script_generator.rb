module RSpec
  module Bash
    class ScriptGenerator
      NOOP = lambda { |*| '' }
      SCRIPTS = {
        conditionals: File.expand_path('../script_generator/conditional.sh', __FILE__),
        controller: File.expand_path('../script_generator/controller.sh', __FILE__)
      }
      SPIES = {
        builtin: lambda { |name|
          <<-EOF
            #{name}() {
              __rspec_bash_call_stubbed '#{name}' "${@}"

              builtin #{name} $@
            }
          EOF
        },
      }
      STUBS = {
        function: lambda { |name|
          <<-EOF
            #{name}() {
              __rspec_bash_call_stubbed '#{name}' "${@}"
            }
          EOF
        },

        function_in_subshell: lambda { |name|
          "#{name}()(__rspec_bash_call_stubbed '#{name}' \"${@}\")\n"
        }
      }

      def self.generate(script)
        buffer = ""
        buffer << "builtin . '#{SCRIPTS[:controller]}'\n"
        buffer << "builtin . '#{SCRIPTS[:conditionals]}'" if script.has_conditional_stubs?
        buffer << "\n"

        script.stubs.keys.each do |name|
          stub_def = script.stubs[name]

          if stub_def[:call_original] then
            buffer << SPIES[:builtin].call(name)
          elsif stub_def[:subshell] == false then
            buffer << STUBS[:function].call(name)
          else
            buffer << STUBS[:function_in_subshell].call(name)
          end
        end

        buffer << "\n"
        buffer << script.source
        buffer
      end
    end
  end
end