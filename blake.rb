# encoding: utf-8

class Integer
	def ror(shift, word_size = size)
		word_size *= 8
		self >> shift | (self << (word_size - shift) & (2 ** word_size - 1))
	end
end

class Blake
	@@iv512 = [
		0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
		0x510e527fade682d1, 0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
	]

	@@iv384 = [
		0xcbbb9d5dc1059ed8, 0x629a292a367cd507, 0x9159015a3070dd17, 0x152fecd8f70e5939,
		0x67332667ffc00b31, 0x8eb44a8768581511, 0xdb0c2e0d64f98fa7, 0x47b5481dbefa4fa4
	]

	@@iv256 = [
		0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
		0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
	]

	@@iv224 = [
		0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939,
		0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4
	]

	@@π8 = [
		0x243f6a8885a308d3, 0x13198a2e03707344, 0xa4093822299f31d0, 0x082efa98ec4e6c89,
		0x452821e638d01377, 0xbe5466cf34e90c6c, 0xc0ac29b7c97c50dd, 0x3f84d5b5b5470917,
		0x9216d5d98979fb1b, 0xd1310ba698dfb5ac, 0x2ffd72dbd01adfb7, 0xb8e1afed6a267e96,
		0xba7c9045f12c7f99, 0x24a19947b3916cf7, 0x0801f2e2858efc16, 0x636920d871574e69
	]

	@@π4 = [
		0x243f6a88, 0x85a308d3, 0x13198a2e, 0x03707344,
		0xa4093822, 0x299f31d0, 0x082efa98, 0xec4e6c89,
		0x452821e6, 0x38d01377, 0xbe5466cf, 0x34e90c6c,
		0xc0ac29b7, 0xc97c50dd, 0x3f84d5b5, 0xb5470917
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
		@output_size = output_size
		@output_words = output_size /= 8
		if @output_words <= 32
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
		input[-1] = (input[-1].ord | 0x01).chr if @output_words % 32 == 0 # set last marker bit
		input << [total_bits >> 64].pack('Q>').force_encoding('binary') if @word_size == 8 # append high-order bytes of input bit length
		input << [total_bits & 0xffffffffffffffff].pack('Q>').force_encoding('binary') # append low-order bytes of input bit length 
		
		@state = case @output_words
			when 28 then @@iv224.clone
			when 32 then @@iv256.clone
			when 48 then @@iv384.clone
			when 64 then @@iv512.clone
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

		@state.pack(@pack_code + '*')[0...@output_words]
	end
	alias :hash :digest

	def Blake.digest(input, *args)
		Blake.new(*args).digest(input)
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
	puts Blake.digest(input, size).bytes.map {|b| '%02x' % b }.join
end
