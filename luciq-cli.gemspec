# frozen_string_literal: true

require_relative 'lib/luciq/version'

Gem::Specification.new do |spec|
  spec.name          = 'luciq-cli'
  spec.version       = Luciq::VERSION
  spec.authors       = ['Ahmed Hany']
  spec.email         = ['ahany@luciq.ai']

  spec.summary       = 'Luciq CLI for developers'
  spec.description   = 'Interact with Luciq from the command line'
  spec.homepage      = 'https://github.com/Instabug/luciq-cli'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Instabug/luciq-cli'
  spec.metadata['changelog_uri'] = 'https://github.com/Instabug/luciq-cli/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'bin/*', 'README.md', 'CHANGELOG.md']

  spec.bindir        = 'bin'
  spec.executables   = ['luciq']
  spec.require_paths = ['lib']

  spec.add_dependency 'multipart-post', '~> 2.3'
  spec.add_dependency 'thor', '~> 1.3'
end
