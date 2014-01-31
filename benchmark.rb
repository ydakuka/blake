require 'benchmark'
require './blake.rb'

rounds = 2000
lengths = [0, 16, 256, 1024, 4 * 1024, 64 * 1024, 1024 * 1024, 1024 * 1024 + 56789]
puts 'rounds: ' + rounds.to_s, 'data lengths: ' + lengths.join(', ')

rand = Random.new
puts "benchmarking blake..."
lengths.each {|length|
	data = rand.bytes(length)
	puts "\tdata length: #{length}"
	puts "\t" + Benchmark.measure { rounds.times { BLAKE.digest(data) }}.to_s
}
