require 'open3'
require 'pry'
require 'pty'
require 'expect'
require 'tempfile'

module BashIt
  class ShellScriptEvaluator
    def eval(script)
      file = Tempfile.new('bash_it')
      file.write(script.to_s)
      file.close

      ShellScript.popenX('/usr/bin/env', 'bash', file.path) do |input, output, error, r2b, b2r, wait_thr|
        b2r.expect("stub>", 1) do |result|
          break if result.nil?

          res = result[0].split("\n").reduce([]) do |acc, line|
            if line == "stub>"
              if acc[-1]
                acc[-1][:type] = :stub
              else
                puts "[WARN] cannot match stub entry: #{line} => #{acc}"
              end
            else
              acc.push({ type: :message, buffer: line })
            end

            acc
          end

          res.each do |type:, buffer:|
            case type
            when :stub
              routine = buffer.split(' ')[0]

              r2b.puts script.stubbed(routine)
              r2b.flush

              b2r.expect('stub-body>', 1)
            when :message
              puts "> #{buffer}"
            end
          end
        end

        input.close
        puts output.read
        puts error.read
      end
    end
  end
end