require 'bash_it'

describe BashIt do
  subject { BashIt::ShellScript.new('echo "Hello World!"') }

  it 'can hijack builtin functions' do
    expect(subject).to call(:echo).once.and_yield { |args|
      """
        builtin echo \"> hijacked!\"
        builtin echo \">> #{args}\"
      """
    }

    run_script subject
  end
end

describe 'install-nvm' do
  subject { BashIt::ShellScript.load(fixture_path("install-nvm.sh")) }

  context 'when nvm is already installed...' do
    it 'does nothing' do
      expect(subject).to call(:declare).and_return 0
      expect(subject).to call(:curl).never

      run_script subject
    end
  end

  context 'when nvm is not installed...' do
    it 'installs it' do
      expect(subject).to call(:declare).exactly(2).times.and_return 1
      expect(subject).to call(:curl).once

      run_script subject
    end
  end
end