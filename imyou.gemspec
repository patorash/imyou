# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imyou/version'

Gem::Specification.new do |spec|
  spec.name          = 'imyou'
  spec.version       = Imyou::VERSION
  spec.authors       = ['patorash']
  spec.email         = ['chariderpato@gmail.com']

  spec.summary       = 'Imyou has feature of attaching popular name to ActiveRecord model.'
  spec.description   = 'Imyou has feature of attaching popular name to ActiveRecord model.'
  spec.homepage      = 'https://github.com/patorash/imyou'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'activerecord', '< 8.2.0', '>= 5.2.0'
  spec.add_development_dependency 'database_cleaner', '< 3.0', '>= 1.99.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.24'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.17'
  spec.add_development_dependency 'rubocop-performance', '~> 1.13'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
  spec.add_development_dependency 'sqlite3', '< 3.0', '>= 1.3'
  spec.add_development_dependency 'concurrent-ruby', '1.3.4'
  spec.add_development_dependency 'mutex_m', '~> 0.1'
  spec.add_development_dependency 'bigdecimal', '~> 3.0'
  spec.add_development_dependency 'base64', '~> 0.1'
  spec.add_development_dependency 'logger', '~> 1.0'
  spec.add_development_dependency 'benchmark', '~> 0.1'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
