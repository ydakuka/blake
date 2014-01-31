# encoding: utf-8

class Integer
	def ror(shift, word_size = size)
		word_size *= 8
		self >> shift | (self << (word_size - shift) & (2 ** word_size - 1))
	end
end

class BLAKE
	@@iv512 = [
		0x6A09E667F3BCC908, 0xBB67AE8584CAA73B, 0x3C6EF372FE94F82B, 0xA54FF53A5F1D36F1,
		0x510E527FADE682D1, 0x9B05688C2B3E6C1F, 0x1F83D9ABFB41BD6B, 0x5BE0CD19137E2179
	]

	@@iv384 = [
		0xCBBB9D5DC1059ED8, 0x629A292A367CD507, 0x9159015A3070DD17, 0x152FECD8F70E5939,
		0x67332667FFC00B31, 0x8EB44A8768581511, 0xDB0C2E0D64F98FA7, 0x47B5481DBEFA4FA4
	]

	@@iv256 = [
		0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
		0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19
	]

	@@iv224 = [
		0xC1059ED8, 0x367CD507, 0x3070DD17, 0xF70E5939,
		0xFFC00B31, 0x68581511, 0x64F98FA7, 0xBEFA4FA4
	]

	@@π8 = [
		0x243F6A8885A308D3, 0x13198A2E03707344, 0xA4093822299F31D0, 0x082EFA98EC4E6C89,
		0x452821E638D01377, 0xBE5466CF34E90C6C, 0xC0AC29B7C97C50DD, 0x3F84D5B5B5470917,
		0x9216D5D98979FB1B, 0xD1310BA698DFB5AC, 0x2FFD72DBD01ADFB7, 0xB8E1AFED6A267E96,
		0xBA7C9045F12C7F99, 0x24A19947B3916CF7, 0x0801F2E2858EFC16, 0x636920D871574E69
	]

	@@π4 = [
		0x243F6A88, 0x85A308D3, 0x13198A2E, 0x03707344,
		0xA4093822, 0x299F31D0, 0x082EFA98, 0xEC4E6C89,
		0x452821E6, 0x38D01377, 0xBE5466CF, 0x34E90C6C,
		0xC0AC29B7, 0xC97C50DD, 0x3F84D5B5, 0xB5470917
	]

	@@σ = [
		[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
		[14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
		[11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4],
		[7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
		[9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13],
		[2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9],
		[12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11],
		[13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10],
		[6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5],
		[10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0],
	]

	@@v_step = [
		[0, 4, 8, 12],
		[1, 5, 9, 13],
		[2, 6, 10, 14],
		[3, 7, 11, 15],
		[0, 5, 10, 15],
		[1, 6, 11, 12],
		[2, 7, 8, 13],
		[3, 4, 9, 14],
	]

	attr_reader :output_size, :salt

	def initialize(output_size = 512, salt = nil)
		@output_size = output_size /= 8
		if @output_size <= 32
			@word_size, @pack_code, @num_rounds, @π, @rot_off = 4, 'L>', 14, @@π4, [16, 12, 8, 7]
		else
			@word_size, @pack_code, @num_rounds, @π, @rot_off = 8, 'Q>', 16, @@π8, [32, 25, 16, 11]
		end
		@mask = 2 ** (@word_size * 8) - 1
		@block_size = @word_size * 16

		self.salt = salt
	end

	def digest(input, salt = @salt)
		# use a different salt just this once if one has been provided
		orig_salt = @salt
		self.salt = salt if salt != @salt

		# pad input and append its length in bits
		input.force_encoding('binary')
		total_bits = input.length * 8
		input << "\x80".force_encoding('binary') # mark the end of the input
		rem = (input.length + @word_size * 2) % @block_size
		input << ("\0" * (@block_size - rem)).force_encoding('binary') if rem > 0 # pad to block size - (2 * word size)
		if @word_size == 8
			input[-1] = (input[-1].ord | 0x01).chr # mark the word size as 64-bit
			input << [total_bits >> 64].pack('Q>').force_encoding('binary') # append high-order bytes of input bit length
		end
		input << [total_bits & 0xffffffffffffffff].pack('Q>').force_encoding('binary') # append low-order bytes of input bit length 
		@state = case @output_size
		when 28 then @@iv224
		when 32 then @@iv256
		when 48 then @@iv384
		when 64 then @@iv512
		end

		@next_offset = 0
		while input.length > 0
			block = input.slice!(0, @block_size).unpack(@pack_code + '*')
			@next_offset += @block_size * 8
			# next_offset must only count input data, not padding, and must be 0 if the block contains only padding
			if @next_offset >= total_bits
				@next_offset = total_bits
				total_bits = 0
			end
			chacha(block)
		end

		@salt = orig_salt

		@state.pack(@pack_code + '*')[0...@output_size]
	end
	alias :hash :digest

	def BLAKE.digest(input, *args)
		BLAKE.new(*args).digest(input)
	end

	def chacha(block)
		v = @state[0..7] + @π[0..7]
		(0..3).each {|i| v[8 + i] ^= @salt[i] }
		if @next_offset != 0
			v[12] ^= @next_offset & @mask
			v[13] ^= @next_offset & @mask
			v[14] ^= @next_offset >> (@word_size * 8)
			v[15] ^= @next_offset >> (@word_size * 8)
		end

		(0...@num_rounds).each {|r|
			(0..7).each {|i|
				step = @@v_step[i]
				a, b, c, d = step.map {|x| v[x] }

				j = @@σ[r % 10][i *= 2]
				k = @@σ[r % 10][i + 1]
				a = a + b + (block[j] ^ @π[k]) & @mask
				d = (d ^ a).ror(@rot_off[0], @word_size)
				c = c + d & @mask
				b = (b ^ c).ror(@rot_off[1], @word_size)
				a = a + b + (block[k] ^ @π[j]) & @mask
				d = (d ^ a).ror(@rot_off[2], @word_size)
				c = c + d & @mask
				b = (b ^ c).ror(@rot_off[3], @word_size)

				v[step[0]], v[step[1]], v[step[2]], v[step[3]] = a, b, c, d
			}
		}

		(0..7).each {|i| @state[i] ^= v[i] ^ v[8 + i] ^ @salt[i & 0x03] }
	end

	private

	def salt=(salt)
		if not salt
			@salt = [0] * 4
		elsif salt.kind_of?(Array) && salt.length == 4
			@salt = salt
		elsif salt.length == @word_size * 4
			@salt = salt.unpack(@pack_code + '*')
		else raise "salt must be #{@word_size * 4} bytes" 
		end
	end
end

if $0 == __FILE__
	input = ARGV.shift.dup
	size = ARGV.shift
	size = (size ? size.to_i : 512)
	puts BLAKE.digest(input, size).bytes.map {|b| '%02x' % b }.join
end
