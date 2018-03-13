require 'bash_it'

describe BashIt, type: :bash do
  subject { BashIt::Script.new('echo "Hello World!"') }

  it 'can hijack builtin functions' do
    expect(subject).to receive(:echo).once.and_yield { |args|
      """
        builtin echo \"> hijacked!\"
        builtin echo \">> #{args}\"
      """
    }

    run_script subject
  end
end

describe 'install-nvm', type: :bash do
  subject { BashIt::Script.load(fixture_path("install-nvm.sh")) }

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

describe 'if.sh', type: :bash do
  subject { BashIt::Script.load(fixture_path("if.sh")) }

  it 'creates "setenv.sh" if it does not exist' do
    allow(subject).to receive('source').with_args('setenv.sh').and_return 0
    expect(subject).to test('-e').with_args('setenv.sh').twice.and_return 1

    run_script subject
  end

  it 'sources "setenv.sh" if it exists' do
    expect(subject).to receive('source').with_args('setenv.sh').once.and_return 0
    allow(subject).to test('-e').with_args('setenv.sh').and_return 1

    run_script subject
  end
end