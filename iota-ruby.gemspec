# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iota/version"

Gem::Specification.new do |spec|
  spec.name          = "iota-ruby"
  spec.version       = IOTA::VERSION
  spec.authors       = ["Vivek Marakana"]
  spec.email         = ["vivek.marakana@gmail.com"]

  spec.summary       = "IOTA API wrapper for Ruby"
  spec.description   = "Ruby gem for the IOTA core"
  spec.homepage      = "https://github.com/vivekmarakana/iota.lib.rb"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- test/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  unless RUBY_PLATFORM =~ /java/
    spec.extensions    = ["ext/ccurl/extconf.rb"]
  end

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake-compiler", "~> 1.0.4"

  unless RUBY_PLATFORM =~ /java/
    spec.add_runtime_dependency "digest-sha3", "~> 1.1"
  end

  spec.add_runtime_dependency "ffi", "~> 1.9.25"
end
