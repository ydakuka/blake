class Integer
  def ror(shift, word_size = size)
    word_size *= 8
    self >> shift | (self << (word_size - shift) & (2**word_size - 1))
  end
end

module Blake
  class Main
    ##
    # IVx for BLAKE-x
    IV64 = [
      0x6a09e667f3bcc908, 0xbb67ae8584caa73b,
      0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1,
      0x510e527fade682d1, 0x9b05688c2b3e6c1f,
      0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
    ].freeze

    IV48 = [
      0xcbbb9d5dc1059ed8, 0x629a292a367cd507,
      0x9159015a3070dd17, 0x152fecd8f70e5939,
      0x67332667ffc00b31, 0x8eb44a8768581511,
      0xdb0c2e0d64f98fa7, 0x47b5481dbefa4fa4
    ].freeze

    ##
    # The values here are the same as the high-order half-words of IV64
    IV32 = [
      0x6a09e667, 0xbb67ae85,
      0x3c6ef372, 0xa54ff53a,
      0x510e527f, 0x9b05688c,
      0x1f83d9ab, 0x5be0cd19
    ].freeze

    ##
    # The values here are the same as the low-order half-words of IV48
    IV28 = [
      0xc1059ed8, 0x367cd507,
      0x3070dd17, 0xf70e5939,
      0xffc00b31, 0x68581511,
      0x64f98fa7, 0xbefa4fa4
    ].freeze

    ##
    # constants for BLAKE-64 and BLAKE-48
    C64 = [
      0x243f6a8885a308d3, 0x13198a2e03707344,
      0xa4093822299f31d0, 0x082efa98ec4e6c89,
      0x452821e638d01377, 0xbe5466cf34e90c6c,
      0xc0ac29b7c97c50dd, 0x3f84d5b5b5470917,
      0x9216d5d98979fb1b, 0xd1310ba698dfb5ac,
      0x2ffd72dbd01adfb7, 0xb8e1afed6a267e96,
      0xba7c9045f12c7f99, 0x24a19947b3916cf7,
      0x0801f2e2858efc16, 0x636920d871574e69
    ].freeze

    ##
    # constants for BLAKE-32 and BLAKE-28
    # Concatenate and the values are the same as the values
    # for the 1st half of C64
    C32 = [
      0x243f6a88, 0x85a308d3,
      0x13198a2e, 0x03707344,
      0xa4093822, 0x299f31d0,
      0x082efa98, 0xec4e6c89,
      0x452821e6, 0x38d01377,
      0xbe5466cf, 0x34e90c6c,
      0xc0ac29b7, 0xc97c50dd,
      0x3f84d5b5, 0xb5470917
    ].freeze

    ##
    # the 10 permutations of: 0,...15}
    SIGMA = [
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
    ].freeze

    V_STEP = [
      [0, 4, 8, 12],
      [1, 5, 9, 13],
      [2, 6, 10, 14],
      [3, 7, 11, 15],
      [0, 5, 10, 15],
      [1, 6, 11, 12],
      [2, 7, 8, 13],
      [3, 4, 9, 14],
    ].freeze

    MASK64BITS = 0xFFFFFFFFFFFFFFFF

    attr_reader :output_size, :salt

    def initialize(output_size = 512, salt = nil)
      @output_size = output_size
      @output_words = output_size /= 8

      if @output_words <= 32
        @word_size  = 4
        @pack_code  = 'L>'
        @num_rounds = 14
        @pi         = C32
        @rot_off    = [16, 12, 8, 7]
      else
        @word_size  = 8
        @pack_code  = 'Q>'
        @num_rounds = 16
        @pi         = C64
        @rot_off    = [32, 25, 16, 11]
      end

      self.salt = salt
    end

    def mask
      @mask ||= 2**(@word_size * 8) - 1
    end

    def block_size
      @block_size ||= @word_size * 16
    end

    def digest(input, salt = @salt)
      # use a different salt just this once if one has been provided
      orig_salt = @salt
      self.salt = salt if salt != @salt

      # pad input and append its length in bits
      total_bits = input.length * 8
      input << "\x80" # mark the end of the input
      rem = (input.length + @word_size * 2) % block_size
      # pad to block size - (2 * word size)
      input << ("\0" * (block_size - rem)) if rem.positive?
      # set last marker bit
      input[-1] = (input[-1].ord | 0x01).chr if (@output_words % 32).zero?
      # append high-order bytes of input bit length
      input << [total_bits >> 64].pack('Q>') if @word_size == 8
      # append low-order bytes of input bit length
      input << [total_bits & MASK64BITS].pack('Q>')

      @state = case @output_words
               when 28 then IV28.dup
               when 32 then IV32.dup
               when 48 then IV48.dup
               when 64 then IV64.dup
               end

      @next_offset = 0

      while input.length.positive?
        block = input.slice!(0, block_size).unpack(@pack_code + '*')
        @next_offset += block_size * 8
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

    alias hash digest

    def self.digest(input, *args)
      Main.new(*args).digest(input)
    end

    def chacha(block)
      v = @state[0..7] + @pi[0..7]
      (0..3).each { |i| v[8 + i] ^= @salt[i] }
      if @next_offset != 0
        v[12] ^= @next_offset & mask
        v[13] ^= @next_offset & mask
        v[14] ^= @next_offset >> (@word_size * 8)
        v[15] ^= @next_offset >> (@word_size * 8)
      end

      (0...@num_rounds).each do |r|
        (0..7).each do |i|
          step = V_STEP[i]
          a, b, c, d = step.map { |x| v[x] }

          j = SIGMA[r % 10][i *= 2]
          k = SIGMA[r % 10][i + 1]
          a = a + b + (block[j] ^ @pi[k]) & mask
          d = (d ^ a).ror(@rot_off[0], @word_size)
          c = c + d & mask
          b = (b ^ c).ror(@rot_off[1], @word_size)
          a = a + b + (block[k] ^ @pi[j]) & mask
          d = (d ^ a).ror(@rot_off[2], @word_size)
          c = c + d & mask
          b = (b ^ c).ror(@rot_off[3], @word_size)

          v[step[0]] = a
          v[step[1]] = b
          v[step[2]] = c
          v[step[3]] = d
        end
      end

      (0..7).each { |i| @state[i] ^= v[i] ^ v[8 + i] ^ @salt[i & 0x03] }
    end

  private

    def salt=(salt)
      if !salt
        @salt = [0] * 4
      elsif salt.is_a?(Array) && salt.length == 4
        @salt = salt
      elsif salt.length == @word_size * 4
        @salt = salt.unpack(@pack_code + '*')
      else raise "salt must be #{@word_size * 4} bytes"
      end
    end
  end
end
