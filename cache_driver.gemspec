# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cache_driver/version'

Gem::Specification.new do |spec|
  spec.name          = "cache_driver"
  spec.version       = CacheDriver::VERSION
  spec.authors       = ["goshan"]
  spec.email         = ["goshan.hanqiu@gmail.com"]

  spec.summary       = %q{A cache adapter for model accepting file or redis}
  spec.description   = %q{make rails model act as ActiveRecord, but not save data into database but cache system, file or redis}
  spec.homepage      = "https://github.com/goshan/cache_driver"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #  raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end
