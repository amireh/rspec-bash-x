# coding: utf-8

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "rspec/bash/version"

Gem::Specification.new do |spec|
  spec.name          = 'rspec-bash-x'
  spec.version       = RSpec::Bash::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.license       = 'AGPL-3.0'
  spec.author        = 'Ahmad Amireh'
  spec.email         = 'ahmad@instructure.com'
  spec.summary       = 'Test Bash scripts with RSpec.'

  spec.files         = `git ls-files -- ext lib`.split("\n")
  spec.files        += %w[README.md LICENSE.md CHANGELOG.md]
  spec.test_files    = Dir.glob('spec/')
  spec.require_paths = ['lib']
  spec.executables   = %w()
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'rspec-support', '~> 3.6'
  spec.add_runtime_dependency 'rspec-mocks', '~> 3.6'
end
