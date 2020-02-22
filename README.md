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
gem install blake.rb
```

## Usage

```ruby
require 'blake'
```

The output size and salt can be specified, or left as their defaults of 512 and nil.

By default:
```ruby
Blake.digest("The quick brown fox jumps over the lazy dog").unpack('H*').join
#=> "1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451"
```

When output size is specified:
```ruby
Blake.digest("The quick brown fox jumps over the lazy dog", 224).unpack('H*').join
#=> "c8e92d7088ef87c1530aee2ad44dc720cc10589cc2ec58f95a15e51b"

Blake.digest("The quick brown fox jumps over the lazy dog", 256).unpack('H*').join
#=> "7576698ee9cad30173080678e5965916adbb11cb5245d386bf1ffda1cb26c9d7"

Blake.digest("The quick brown fox jumps over the lazy dog", 384).unpack('H*').join
#=> "67c9e8ef665d11b5b57a1d99c96adffb3034d8768c0827d1c6e60b54871e8673651767a2c6c43d0ba2a9bb2500227406"

Blake.digest("The quick brown fox jumps over the lazy dog", 512).unpack('H*').join
#=> "1f7e26f63b6ad25a0896fd978fd050a1766391d2fd0471a77afb975e5034b7ad2d9ccf8dfb47abbbe656e1b82fbc634ba42ce186e8dc5e1ce09a885d41f43451"
```

When salt is specified:
```ruby
salt = [0, 2, 4, 8]

Blake.digest("The quick brown fox jumps over the lazy dog", 224, salt).unpack('H*').join
#=> "9c745e156e27705b3dfa07cd26d623991655c049242953c4a331d133"

Blake.digest("The quick brown fox jumps over the lazy dog", 256, salt).unpack('H*').join
#=> "d24ce44e7964dba5e27a20e80377ebef308215b7ff6da949dc96190ebd5818c6"

Blake.digest("The quick brown fox jumps over the lazy dog", 384, salt).unpack('H*').join
#=> "42e7983093f97c4fb8238bbc9378251b274c8f0f7ffd28ca73935a34e1f567dfee6bf31d6cea5766c92fdf4a3a5d3718"

Blake.digest("The quick brown fox jumps over the lazy dog", 512, salt).unpack('H*').join
#=> "930cddb5e7b41ba85b8179e14617fc4cb6372ba565b479c8cb726ef8c2a6526ff1b901af461ef9a6f91d71bda8079c0cc5e284f44014a1d2ec0d8d7814ae33f6"
```
