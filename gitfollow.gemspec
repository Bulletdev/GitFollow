# frozen_string_literal: true

require_relative 'lib/gitfollow/version'

Gem::Specification.new do |spec|
  spec.name          = 'gitfollow'
  spec.version       = GitFollow::VERSION
  spec.authors       = ['Michael D. Bullet']
  spec.email         = ['contato@michaelbullet.com']

  spec.summary       = 'Track GitHub followers and unfollows with ease'
  spec.description   = 'A CLI tool to monitor your GitHub followers, detect new followers and unfollows, and generate detailed reports with automated notifications.'
  spec.homepage      = 'https://github.com/bulletdev/gitfollow'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4.5'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "#{spec.homepage}.git"
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['documentation_uri'] = "#{spec.homepage}/blob/main/README.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['lib/**/*.rb', 'bin/*', 'README.md', 'LICENSE', 'CHANGELOG.md']
  spec.bindir        = 'bin'
  spec.executables   = ['gitfollow']
  spec.require_paths = ['lib']

  # Runtime dependencies
  spec.add_dependency 'colorize', '~> 1.1'
  spec.add_dependency 'csv', '~> 3.2'
  spec.add_dependency 'dotenv', '~> 3.0'
  spec.add_dependency 'octokit', '~> 8.0'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'tty-spinner', '~> 0.9'
  spec.add_dependency 'tty-table', '~> 0.12'

  # Development dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.60'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.26'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'vcr', '~> 6.2'
  spec.add_development_dependency 'webmock', '~> 3.19'
end
