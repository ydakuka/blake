require 'spec_helper'

RSpec.describe Blake do
  specify do
    expect(Blake.digest('')).to be_instance_of String
  end

  specify do
    expect(Blake.digest('').unpack('H*').join).to \
      eq 'a8cfbbd73726062df0c6864dda65defe58ef0cc52a5625090fa17601e1eecd1b628e94f396ae402a00acc9eab77b4d4c2e852aaaa25a636d80af3fc7913ef5b8'
  end

  specify do
    expect(Blake.digest('The quick brown fox jumps over the lazy dog').unpack('H*').join).to \
      eq '1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451'
  end

  context 'when output size is unknown' do
    let(:input) { 'abc' }
    let(:output_size) { 50 }

    specify do
      expect { Blake.digest(input, output_size) }.to \
        raise_error TypeError, 'unknown output size'
    end
  end

  context 'when input is packed binary array' do
    let(:input) { [7, 63, 152, 144].pack('C*') }

    specify do
      expect(Blake.digest(input, 224).unpack('H*').join).to \
        eq '88bcb791826d2e864e450234a0fff51e9038bbc0789f8a80a3c8722e'
    end

    specify do
      expect(Blake.digest(input, 256).unpack('H*').join).to \
        eq 'a23e8b68b62c682f592fbfc9e70b7177cd0ff8154d6e895bce1b680ef4907ea0'
    end

    specify do
      expect(Blake.digest(input, 384).unpack('H*').join).to \
        eq 'c6cfa889eee34ce0dbd85d029b9ae067bc645ae58ece988f249a5923e787eeaa7d61cf958297c5484edd109269e3739d'
    end

    specify do
      expect(Blake.digest(input, 512).unpack('H*').join).to \
        eq 'c938374e8273b1a8dcfcd970d85e229e2ca422e3dcb64fdbec5ec055abc0d3c18bee1f077d37c5b08737a0510e2d3d82735a94669a1e124d92d4d63c55b5cfb2'
    end
  end

  context 'when salt is present' do
    let(:salt) { [0, 2, 4, 8] }

    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 224, salt).unpack('H*').join).to \
        eq '9c745e156e27705b3dfa07cd26d623991655c049242953c4a331d133'
    end

    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 256, salt).unpack('H*').join).to \
        eq 'd24ce44e7964dba5e27a20e80377ebef308215b7ff6da949dc96190ebd5818c6'
    end

    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 384, salt).unpack('H*').join).to \
        eq '42e7983093f97c4fb8238bbc9378251b274c8f0f7ffd28ca73935a34e1f567dfee6bf31d6cea5766c92fdf4a3a5d3718'
    end

    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 512, salt).unpack('H*').join).to \
        eq '930cddb5e7b41ba85b8179e14617fc4cb6372ba565b479c8cb726ef8c2a6526ff1b901af461ef9a6f91d71bda8079c0cc5e284f44014a1d2ec0d8d7814ae33f6'
    end
  end

  context 'when test 224 hash' do
    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 224).unpack('H*').join).to \
        eq 'c8e92d7088ef87c1530aee2ad44dc720cc10589cc2ec58f95a15e51b'
    end

    specify do
      expect(Blake.digest('', 224).unpack('H*').join).to \
        eq '7dc5313b1c04512a174bd6503b89607aecbee0903d40a8a569c94eed'
    end

    specify do
      expect(Blake.digest('BLAKE', 224).unpack('H*').join).to \
        eq 'cfb6848add73e1cb47994c4765df33b8f973702705a30a71fe4747a3'
    end

    specify do
      expect(Blake.digest("\0", 224).unpack('H*').join).to \
        eq '4504cb0314fb2a4f7a692e696e487912fe3f2468fe312c73a5278ec5'
    end
  end

  context 'when test 256 hash' do
    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 256).unpack('H*').join).to \
        eq '7576698ee9cad30173080678e5965916adbb11cb5245d386bf1ffda1cb26c9d7'
    end

    specify do
      expect(Blake.digest('', 256).unpack('H*').join).to \
        eq '716f6e863f744b9ac22c97ec7b76ea5f5908bc5b2f67c61510bfc4751384ea7a'
    end

    specify do
      expect(Blake.digest('BLAKE', 256).unpack('H*').join).to \
        eq '07663e00cf96fbc136cf7b1ee099c95346ba3920893d18cc8851f22ee2e36aa6'
    end

    specify do
      expect(Blake.digest("\0", 256).unpack('H*').join).to \
        eq '0ce8d4ef4dd7cd8d62dfded9d4edb0a774ae6a41929a74da23109e8f11139c87'
    end
  end

  context 'when test 384 hash' do
    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 384).unpack('H*').join).to \
        eq '67c9e8ef665d11b5b57a1d99c96adffb3034d8768c0827d1c6e60b54871e8673651767a2c6c43d0ba2a9bb2500227406'
    end

    specify do
      expect(Blake.digest('', 384).unpack('H*').join).to \
        eq 'c6cbd89c926ab525c242e6621f2f5fa73aa4afe3d9e24aed727faaadd6af38b620bdb623dd2b4788b1c8086984af8706'
    end

    specify do
      expect(Blake.digest('BLAKE', 384).unpack('H*').join).to \
        eq 'f28742f7243990875d07e6afcff962edabdf7e9d19ddea6eae31d094c7fa6d9b00c8213a02ddf1e2d9894f3162345d85'
    end

    specify do
      expect(Blake.digest("\0", 384).unpack('H*').join).to \
        eq '10281f67e135e90ae8e882251a355510a719367ad70227b137343e1bc122015c29391e8545b5272d13a7c2879da3d807'
    end
  end

  context 'when test 512 hash' do
    specify do
      expect(Blake.digest('The quick brown fox jumps over the lazy dog', 512).unpack('H*').join).to \
        eq '1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451'
    end

    specify do
      expect(Blake.digest('', 512).unpack('H*').join).to \
        eq 'a8cfbbd73726062df0c6864dda65defe58ef0cc52a5625090fa17601e1eecd1b628e94f396ae402a00acc9eab77b4d4c2e852aaaa25a636d80af3fc7913ef5b8'
    end

    specify do
      expect(Blake.digest('BLAKE', 512).unpack('H*').join).to \
        eq '7bf805d0d8de36802b882e65d0515aa7682a2be97a9d9ec1399f4be2eff7de07684d7099124c8ac81c1c7c200d24ba68c6222e75062e04feb0e9dd589aa6e3b7'
    end

    specify do
      expect(Blake.digest("\0", 512).unpack('H*').join).to \
        eq '97961587f6d970faba6d2478045de6d1fabd09b61ae50932054d52bc29d31be4ff9102b9f69e2bbdb83be13d4b9c06091e5fa0b48bd081b634058be0ec49beb3'
    end
  end
end
