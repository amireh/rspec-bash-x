RSpec.describe RSpec::Bash::MessageDecoder do
  subject { described_class.method(:decode) }

  it 'works' do
    buffer = ''
    buffer << '3;' # number of frames
    buffer << '3;4 a'
    buffer << '2;4 '
    buffer << '5;1 xyz'

    frames, err = subject.call(buffer)

    expect(err).to eq(nil)
    expect(frames).to eq([
      [ 4, 'a'  ],
      [ 4, ''   ],
      [ 1, 'xyz']
    ])
  end

  it 'returns nil on invalid payload' do
    frames, err = subject.call 'foobar'

    expect(frames).to eq nil
    expect(err).to match('invalid payload')
  end

  it 'returns nil if the payload is incomplete' do
    buffer = ''
    buffer << '3;' # number of frames
    buffer << '3;4 a'
    buffer << '2;4 '
    buffer << '5;1 xyz'

    frames, err = subject.call(buffer.slice(0..3))

    expect(frames).to eq(nil)
    expect(err).to match('invalid payload')
  end
end