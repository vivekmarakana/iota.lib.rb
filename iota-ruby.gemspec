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

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- test/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_dependency "digest-sha3", "~> 1.1"
end
