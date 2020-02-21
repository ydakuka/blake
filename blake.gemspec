# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'blake/version'

Gem::Specification.new do |spec|
  spec.name     = 'blake.rb'
  spec.version  = Blake::VERSION
  spec.license  = 'MIT'
  spec.homepage = 'https://github.com/ydakuka/blake.rb'
  spec.summary  = 'BLAKE hash function library for ruby'
  spec.platform = Gem::Platform::RUBY

  spec.authors = ['Daniel Cavanagh (danielcavanagh)']

  spec.description = <<-DESCRIPTION.split.join ' '
    BLAKE is a cryptographic hash function based on Dan Bernstein's ChaCha
    stream cipher, but a permuted copy of the input block, XORed with round
    constants, is added before each ChaCha round. Like SHA-2, there are two
    variants differing in the word size. ChaCha operates on a 4×4 array of
    words. BLAKE repeatedly combines an 8-word hash value with 16 message words,
    truncating the ChaCha result to obtain the next hash value. BLAKE-256 and
    BLAKE-224 use 32-bit words and produce digest sizes of 256 bits and 224
    bits, respectively, while BLAKE-512 and BLAKE-384 use 64-bit words and
    produce digest sizes of 512 bits and 384 bits, respectively.
  DESCRIPTION

  spec.metadata = {
    'homepage_uri' => 'https://github.com/ydakuka/blake.rb',
    'source_code_uri' => 'https://github.com/ydakuka/blake.rb',
    'bug_tracker_uri' => 'https://github.com/ydakuka/blake.rb/issues',
  }.freeze

  spec.require_paths = ['lib']

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match %r{^(test|spec)/}
  end

  spec.add_development_dependency 'bundler',             '~> 1.16'
  spec.add_development_dependency 'rake',                '~> 12.3'
  spec.add_development_dependency 'pry',                 '~> 0.12'
  spec.add_development_dependency 'rubocop',             '~> 0.73'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
end
