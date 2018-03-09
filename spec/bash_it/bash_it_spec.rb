require 'bash_it'

describe 'install-nvm' do
  it 'works' do
    script = BashIt::ShellScript.new(Support.fixture_path("install-nvm.sh"))
    script.stub("declare") { "return 1" }
    script.stub("echo") { |args|
      """
        builtin echo #{args}
        return 1
      """
    }

    evaluator = BashIt::ShellScriptEvaluator.new
    expect(
      evaluator.eval(script)
    ).to eq(false)
  end
end