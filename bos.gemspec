# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bos/version'

Gem::Specification.new do |spec|
  spec.name          = "bos"
  spec.version       = BOS::VERSION
  spec.authors       = ["Jingkai He"]
  spec.email         = ["jaxihe@gmail.com"]
  spec.summary       = %q{Bank of Scotland screen scraper}
  spec.description   = %q{Bank of Scotland screen scraper}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mechanize", "~> 2.7.3"
  spec.add_dependency "thor", "~> 0.19.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.4.3"
end
