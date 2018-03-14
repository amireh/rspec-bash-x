RSpec.describe '.test_for()', type: :bash do
  it 'works using "test"' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if test -n "${foo}"; then
        echo "yes"
      fi

      test ! -n "${foo}" && echo "yes"

      test -n "${foo}" && echo "yes"
    EOF

    expect(subject).to test_for('-n FOO').twice.and_always_return(1)
    expect(subject).to test_for('! -n FOO').once.and_call_original

    run_script subject

    expect(subject.stdout).to eq('')
  end

  it 'bans the use of .with_args()'

  it 'works using "["' do
    subject = RSpec::Bash::Script.new <<-EOF
      foo="FOO"

      if [ -n "${foo}" ]; then
        echo "yes"
      fi

      [ -n "${foo}" ] && echo "yes"
    EOF

    expect(subject).to test_for('-n FOO').and_always_return 1

    run_script subject

    expect(subject.stdout).to eq('')
  end
end
