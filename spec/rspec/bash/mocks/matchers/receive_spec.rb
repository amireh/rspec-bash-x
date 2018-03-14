RSpec.describe '.receive()', type: :bash do
  subject { RSpec::Bash::Script.new('echo "Hello World!"') }

  it 'can hijack builtin functions' do
    expect(subject).to receive(:echo).once.and_yield { |args|
      """
        builtin echo \"> hijacked!\"
        builtin echo \">> #{args}\"
      """
    }

    run_script subject, []
  end

  describe '.with_args' do
    subject {
      RSpec::Bash::Script.new <<-EOF
        echo "one"
        echo "one two"
        echo "three"
      EOF
    }

    it 'can pass args' do
      expect(subject).to (
        receive(:echo)
          .thrice
          .with_args('one').and_yield { |x| "builtin echo 'one+1'" }
          .with_args('one two').and_return(1)
          .and_yield { |x| "builtin echo \"$1+1\"" }
      )

      run_script subject

      expect(subject.stdout.lines).to eq([
        "one+1\n",
        "three+1\n"
      ])
    end
  end
end
