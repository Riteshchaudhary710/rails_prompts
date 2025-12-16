# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-12-15

### Added
- Complete README documentation with usage examples
- CHANGELOG.md for version tracking
- LICENSE.txt (MIT License)

## [0.0.1] - 2025-12-15

### Added
- Initial release of Rails Prompts gem
- Core functionality for rendering AI prompts from ERB templates
- Support for markdown files with `.md.erb` extension
- `render_prompt` method to render templates with variable interpolation
- `available_prompts` method to list all available prompt templates
- Configurable prompts directory (defaults to `app/prompts`)
- Clean variable binding using anonymous Structs for template isolation
- Comprehensive documentation and usage examples

### Features
- ERB template support with trim mode
- Rails integration with automatic directory detection
- Flexible variable interpolation in prompt templates
- Error handling for missing templates
- Support for Ruby >= 2.7.0 and Rails >= 6.0

[0.0.1]: https://github.com/riteshchaudhary/rails_prompts/releases/tag/v0.0.1
