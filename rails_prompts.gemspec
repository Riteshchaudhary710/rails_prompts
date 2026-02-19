require_relative 'lib/rails_prompts/version'

Gem::Specification.new do |s|
  s.name               = "rails_prompts"
  s.version            = RailsPrompts::VERSION
  s.authors            = ['Ritesh Chaudhary']
  s.email              = ['chaudharyritesh7100@gmail.com']
  s.summary            = 'Manage AI prompts in Rails applications with multiple template engine support'
  s.description        = 'A Ruby gem for managing AI prompts with support for ERB, HAML, Slim, YAML, and JSON templates. Centralizes prompt management and makes them easier to review, version control, and modify.'
  s.homepage           = 'https://github.com/Riteshchaudhary710/rails_prompts'
  s.license            = 'MIT'
  s.required_ruby_version = '>= 2.7.0'

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/Riteshchaudhary710/rails_prompts/issues',
    'changelog_uri'     => 'https://github.com/Riteshchaudhary710/rails_prompts/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/Riteshchaudhary710/rails_prompts/blob/master/README.md',
    'source_code_uri'   => 'https://github.com/Riteshchaudhary710/rails_prompts',
    'rubygems_mfa_required' => 'true'
  }

  s.files = Dir['lib/**/*.rb', 'lib/**/*.rake', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']
  s.require_paths = ['lib']

  # Runtime dependencies
  s.add_dependency 'rails', '>= 6.0'

  # Optional template engine dependencies (soft dependencies)
  # Users should add these to their Gemfile if they want to use them:
  # - haml (~> 6.0) for .md.haml templates
  # - slim (~> 5.0) for .md.slim templates

  # Development dependencies
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rubocop', '~> 1.0'
  s.add_development_dependency 'haml', '~> 6.0'
  s.add_development_dependency 'slim', '~> 5.0'
end
