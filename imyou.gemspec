# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "imyou/version"

Gem::Specification.new do |spec|
  spec.name          = "imyou"
  spec.version       = Imyou::VERSION
  spec.authors       = ["patorash"]
  spec.email         = ["chariderpato@gmail.com"]

  spec.summary       = %q{Imyou has feature of attaching popular name to ActiveRecord model.}
  spec.description   = %q{Imyou has feature of attaching popular name to ActiveRecord model.}
  spec.homepage      = "https://github.com/patorash/imyou"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new("< 3".freeze)

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'pry', '~> 0'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
  spec.add_development_dependency 'combustion', '~> 1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
end
