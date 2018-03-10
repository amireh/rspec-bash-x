require 'bash_it'

describe 'install-nvm' do
  it 'works' do
    script = BashIt::ShellScript.new(fixture_path("install-nvm.sh"))

    expect(script).to receive_shell(:declare).exactly(2).times.and_return 1
    expect(script).to receive_shell(:echo).and_yield { |args|
      """
        builtin echo \">> #{args}\"
        return 0
      """
    }

    evaluator = BashIt::ShellScriptEvaluator.new
    evaluator.eval(script)
  end
end