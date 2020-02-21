Blake.rb
========

BLAKE is a cryptographic hash function based on Dan Bernstein's ChaCha stream
cipher, but a permuted copy of the input block, XORed with round constants, is
added before each ChaCha round. Like SHA-2, there are two variants differing in
the word size. ChaCha operates on a 4×4 array of words. BLAKE repeatedly
combines an 8-word hash value with 16 message words, truncating the ChaCha
result to obtain the next hash value. BLAKE-256 and BLAKE-224 use 32-bit words
and produce digest sizes of 256 bits and 224 bits, respectively, while
BLAKE-512 and BLAKE-384 use 64-bit words and produce digest sizes of 512 bits
and 384 bits, respectively.

## Install

```
gem install blake
```

## Usage

```ruby
require 'blake'

blake = Blake.new(output_size, salt)
hash = blake.digest("string to hash")
hash = blake.digest("string to hash", one_time_salt)

hash = Blake.digest("string to hash", output_size, salt)

hash = Blake.digest("string to hash")
```
