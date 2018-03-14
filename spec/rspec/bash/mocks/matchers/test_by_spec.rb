RSpec.describe '.test_by', type: :bash do
  it 'works against "test" and "["' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if [ -n "${foo}" ]; then
        echo "yes"
      fi

      test -n "${foo}" && echo "yes"

      [ -n "BAR" ] && echo "yes"
    EOF

    expect(subject).to (
      test_by('-n')
        .with_args('FOO').twice.and_return(1)
        .with_args('BAR').once.and_return(1)
    )

    run_script subject

    expect(subject.stdout).to eq('')
  end

  it 'attaches a body to each .with_args() invocation' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if [ -n "${foo}" ]; then
        echo "yes foo1"
      fi

      [ -n "${foo}" ] && echo "yes foo2"

      test -n "BAR" && echo "yes bar"
    EOF

    expect(subject).to (
      test_by('-n')
        .thrice
        .with_args('FOO').and_return(1)
        .with_args('FOO').and_return(0)
        .with_args('BAR').and_return(0)
    )

    run_script subject

    expect(subject.stdout.lines).to eq([
      "yes foo2\n",
      "yes bar\n"
    ])
  end

  it 'reports failures in call count' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if [ -n "${foo}" ]; then
        echo "yes"
      fi
    EOF

    expectation = expect(subject).to test_by('-n').twice

    run_script subject

    expect {
      expectation.verify_messages_received(subject)
    }.to raise_error do |e|
      expect(e.to_s).to match(/expected: 2 times with any arguments/)
      expect(e.to_s).to match(/received: 1 time with arguments:/)
    end

    # ban the call by actual rspec-bash
    expect(expectation).to receive_function(:verify_messages_received)
  end

  it 'accounts for the full expression when counting calls' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      test -n "${foo}" && echo "yes"
      test -n "FOO" && echo "yes"
      test -n "BAR" && echo "yes"
    EOF

    expect(subject).to test_by('-n FOO').twice
    expect(subject).to test_by('-n BAR').once

    run_script subject
  end
end
