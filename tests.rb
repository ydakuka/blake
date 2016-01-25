# encoding: utf-8

require 'test/unit'
require_relative 'blake'

class String
	def to_hexstr
		unpack('H*').join
	end
end
 
class TestBLAKE < Test::Unit::TestCase
	def test_class_form
		assert_instance_of(String, BLAKE.digest(''))
	end
	
	def test_object_form
		blake = BLAKE.new()
		assert_instance_of(String, blake.digest(''))
	end
	
	def test_default_output_size_is_512
		assert_equal(512, BLAKE.new().output_size)
	end
	
	def test_256_hash
		assert_equal('7576698ee9cad30173080678e5965916adbb11cb5245d386bf1ffda1cb26c9d7', BLAKE.digest('The quick brown fox jumps over the lazy dog', 256).to_hexstr)
		assert_equal('7576698ee9cad30173080678e5965916adbb11cb5245d386bf1ffda1cb26c9d7', BLAKE.new(256).digest('The quick brown fox jumps over the lazy dog').to_hexstr)
	end
	
	def test_512_hash
		assert_equal('1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451', BLAKE.digest('The quick brown fox jumps over the lazy dog', 512).to_hexstr)
		assert_equal('1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451', BLAKE.new(512).digest('The quick brown fox jumps over the lazy dog').to_hexstr)
	end
	
	def test_multiple_hashes
		blake = BLAKE.new()
		hash = blake.digest('test')
		5.times { assert_equal(hash, blake.digest('test')) }
		assert_not_equal(hash, blake.digest('not equal'))
	end
	
	def test_more_hashes
		assert_equal('716f6e863f744b9ac22c97ec7b76ea5f5908bc5b2f67c61510bfc4751384ea7a', BLAKE.digest('', 256).to_hexstr)
		assert_equal('a8cfbbd73726062df0c6864dda65defe58ef0cc52a5625090fa17601e1eecd1b628e94f396ae402a00acc9eab77b4d4c2e852aaaa25a636d80af3fc7913ef5b8', BLAKE.digest('', 512).to_hexstr)
		assert_equal('07663e00cf96fbc136cf7b1ee099c95346ba3920893d18cc8851f22ee2e36aa6', BLAKE.digest('BLAKE', 256).to_hexstr)
		assert_equal('7bf805d0d8de36802b882e65d0515aa7682a2be97a9d9ec1399f4be2eff7de07684d7099124c8ac81c1c7c200d24ba68c6222e75062e04feb0e9dd589aa6e3b7', BLAKE.digest('BLAKE', 512).to_hexstr)
		assert_equal('0ce8d4ef4dd7cd8d62dfded9d4edb0a774ae6a41929a74da23109e8f11139c87', BLAKE.digest("\0", 256).to_hexstr)
		assert_equal('97961587f6d970faba6d2478045de6d1fabd09b61ae50932054d52bc29d31be4ff9102b9f69e2bbdb83be13d4b9c06091e5fa0b48bd081b634058be0ec49beb3', BLAKE.digest("\0", 512).to_hexstr)
	end
end