RSpec.describe RSpec::Bash, type: :bash do
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
end

RSpec.describe RSpec::Bash, type: :bash do
  subject { RSpec::Bash::Script.new('echo "one=$1 two=$2"') }

  it 'can pass args' do
    run_script subject, [ 'x', 'Y' ]
    expect(subject.stdout).to eq("one=x two=Y\n")
  end
end

RSpec.describe '.with_args', type: :bash do
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

RSpec.describe 'conditionals: "test"', type: :bash do
  subject {
    RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if test -n "${foo}"; then
        echo "yes"
      fi

      test -n "${foo}" && echo "yes"
    EOF
  }

  it 'works' do
    expect(subject).to test('-n').with_args('FOO').and_return 1

    run_script subject

    expect(subject.stdout).to be_empty
  end
end

RSpec.describe 'conditionals: "["', type: :bash do
  it 'works' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if [ -n "${foo}" ]; then
        echo "yes"
      fi

      [ -n "${foo}" ] && echo "yes"
    EOF

    expect(subject).to test('-n').with_args('FOO').and_return 1

    run_script subject

    expect(subject.stdout).to be_empty
  end

  context 'when .with_args is used...' do
    it 'returns the respective codes based on arguments' do
      subject = RSpec::Bash::Script.new <<-EOF
        foo="FOO"
        bar="BAR"

        if [ -n "${foo}" ]; then
          echo "yes foo"
        fi

        [ -n "${bar}" ] && echo "yes bar"
      EOF

      expect(subject).to (
        test('-n')
          .with_args('FOO').and_return(1)
          .with_args('BAR').and_return(0)
      )

      run_script subject

      expect(subject.stdout).to eq("yes bar\n")

    end
  end
end

RSpec.describe 'install-nvm', type: :bash do
  subject { RSpec::Bash::Script.load(fixture_path("install-nvm.sh")) }

  context 'when nvm is already installed...' do
    it 'does nothing' do
      expect(subject).to receive(:declare).and_return 0
      expect(subject).to receive(:curl).never

      run_script subject
    end
  end

  context 'when nvm is not installed...' do
    it 'installs it' do
      expect(subject).to receive(:declare).exactly(2).times.and_return 1
      expect(subject).to receive(:curl).once

      run_script subject
    end
  end
end

RSpec.describe 'if.sh', type: :bash do
  subject { RSpec::Bash::Script.load(fixture_path("if.sh")) }

  it 'creates "setenv.sh" if it does not exist' do
    allow(subject).to receive('source').with_args('setenv.sh').and_return 0
    expect(subject).to (
      test('-e')
        .with_args('setenv.sh')
        .with_args('setenv.sh')
        .twice.and_return 1
    )

    run_script subject
  end

  it 'sources "setenv.sh" if it exists' do
    expect(subject).to receive('source').with_args('setenv.sh').once.and_return 0
    allow(subject).to test('-e').with_args('setenv.sh').and_return 1

    run_script subject
  end
end