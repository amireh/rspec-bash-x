RSpec.describe '.receive()', type: :bash do
  it 'can hijack builtin functions' do
    subject = a_script 'echo "Hello World!"'

    expect(subject).to receive(:echo).once.and_yield { |args|
      """
        builtin echo \"> hijacked!\"
        builtin echo \">> #{args}\"
      """
    }

    run_script subject
  end

  it 'can hijack functions' do
    pending "not sure it's worthwhile, it only affects inlined functions"

    subject = a_script """
      function a() {
        echo 'hi'
      }

      a
    """

    expect(subject).to receive(:a).and_return 0

    run_script subject

    expect(subject.stdout).to eq('')
  end

  describe '.and_call_original' do
    subject { a_script 'echo "Hello World!"' }

    it 'works with builtin functions' do
      expect(subject).to receive(:echo).once.and_call_original

      expect(run_script(subject)).to eq(true)

      expect(subject.stdout).to eq("Hello World!\n")
    end
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
