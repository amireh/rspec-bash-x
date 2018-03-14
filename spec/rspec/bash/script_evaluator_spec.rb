RSpec.describe RSpec::Bash::ScriptEvaluator, type: :bash do
  subject { RSpec::Bash::Script.new('echo "one=$1 two=$2"') }

  it 'can pass args to the script' do
    run_script subject, [ 'x', 'Y' ]

    expect(subject.stdout).to eq("one=x two=Y\n")
  end
end
