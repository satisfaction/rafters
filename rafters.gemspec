# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rafters/version'

Gem::Specification.new do |spec|
  spec.name          = "rafters"
  spec.version       = Rafters::VERSION
  spec.authors       = ["Andrew Hite"]
  spec.email         = ["andrew@andrew-hite.com"]
  spec.description   = %q{Rafters lets you think about each page of your application as a collection of small pieces instead of monolithic, difficult to maintain views.}
  spec.summary       = %q{Rafters lets you think about each page of your application as a collection of small pieces instead of monolithic, difficult to maintain views.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7.4"
  spec.add_development_dependency "capybara", "~> 2.2.1"
  spec.add_development_dependency "debugger", "~> 1.6.5"
  spec.add_development_dependency "rake", "~> 10.1.1"
  spec.add_development_dependency "rspec-rails", "~> 2.14.1"
  spec.add_development_dependency "yard", "~> 0.8.7.3"
  spec.add_development_dependency 'coveralls', "~> 0.7.0"
  spec.add_development_dependency 'fuubar', '~> 1.3.2'
  spec.add_development_dependency 'guard', '~> 1.8.3'
  spec.add_development_dependency 'guard-rspec', '~> 3.0.3'
  spec.add_development_dependency 'guard-spork', '~> 1.5.1'
  spec.add_development_dependency 'spork', '~> 0.9.2'

  spec.add_dependency "hashie", "~> 2.0.5"
  spec.add_dependency "rails", "~> 4.0"
  spec.add_dependency "sprockets", "~> 2.2.2"
end
