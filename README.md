ruby-blake
==========

blake hash function library for ruby

## usage

the output size and salt can be specified, or left as their defaults of 512 and nil

```
blake = BLAKE.new(output_size, salt)
hash = blake.digest("string to hash")
hash = blake.digest("string to hash", one_time_salt)

hash = BLAKE.digest("string to hash", output_size, salt)

hash = BLAKE.digest("string to hash")
```

it can also be run from the command line

```
./blake.rb "string to hash" output_size
```
