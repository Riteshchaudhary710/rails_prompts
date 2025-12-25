# Rails Prompts

A Ruby gem for managing AI prompts in Rails applications using ERB templates stored in markdown files. Centralize your prompts, make them easier to review, version control, and modify.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails_prompts'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rails_prompts
```

### Quick Setup with Generator

After installing the gem, run the install generator to automatically create the `app/prompts` directory with a sample template:

```bash
rails generate rails_prompts:install
```

Or use the rake task:

```bash
rake rails_prompts:install
```

This will:
- Create the `app/prompts` directory
- Add a sample prompt template
- Automatically configure Rails autoload paths (no manual configuration needed!)

## Usage

### 1. Create Your Prompts Directory

**Option A: Automatic Setup (Recommended)**

Use the generator (as shown above):

```bash
rails generate rails_prompts:install
```

**Option B: Manual Setup**

Create the directory manually:

```bash
mkdir -p app/prompts
```

**🎉 When using `app/prompts`, no additional configuration is required!** The gem automatically adds this directory to Rails autoload paths.

### 2. Using Custom Prompts Directory

If you prefer to store prompts in a different location (e.g., `lib/prompts`), you need to configure it in `config/application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # ... other config ...
    
    # Add custom prompts directory to autoload paths
    config.autoload_paths << Rails.root.join('lib', 'prompts')
    
    # Configure RailsPrompts to use the custom directory
    config.after_initialize do
      RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')
    end
  end
end
```

### 3. Create Prompt Templates

Create prompt templates as `.md.erb` files in the `app/prompts/` directory. Use ERB syntax to interpolate variables.

**Example: `app/prompts/summarize_text.md.erb`**

```erb
You are an expert content summarizer. Please summarize the following text:

Text to summarize:
---
<%= text %>
---

Provide a concise summary in <%= max_words %> words or less.
```

### 4. Render Prompts in Your Application

Use `RailsPrompts.render_prompt` to render your templates with variables:

```ruby
# In your controller or service
prompt = RailsPrompts.render_prompt('summarize_text', {
  text: "Long article text here...",
  max_words: 100
})

# Use the prompt with your AI service
response = OpenAI::Client.new.chat(
  parameters: {
    model: "gpt-4",
    messages: [{ role: "user", content: prompt }]
  }
)
```

### 5. List Available Prompts

You can get a list of all available prompt templates:

```ruby
RailsPrompts.available_prompts
# => ["summarize_text", "generate_title", "code_review"]
```

## Configuration

### Default Directory (No Setup Required)

When using `app/prompts`, the gem automatically:
- Adds the directory to Rails autoload paths
- Adds it to eager load paths (for production)
- Configures itself to look for templates there

### Custom Directory Setup

To use a custom directory like `lib/prompts` or any other location:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Add your custom directory to autoload paths
    config.autoload_paths << Rails.root.join('lib', 'prompts')
    
    # Tell RailsPrompts where to find templates
    config.after_initialize do
      RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')
    end
  end
end
```

Alternatively, you can configure it in an initializer:

```ruby
# config/initializers/rails_prompts.rb
RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')

# Note: You still need to add the path to autoload_paths in application.rb
```

## Examples

### Example 1: Code Review Prompt

**`app/prompts/code_review.md.erb`**

```erb
You are an expert code reviewer. Please review the following <%= language %> code:

```<%= language %>
<%= code %>
```

Focus on:
- Code quality and best practices
- Potential bugs or security issues
- Performance considerations
- Readability and maintainability

Provide constructive feedback.
```

**Usage:**

```ruby
prompt = RailsPrompts.render_prompt('code_review', {
  language: 'ruby',
  code: File.read('app/models/user.rb')
})
```

### Example 2: Generate Product Description

**`app/prompts/product_description.md.erb`**

```erb
Create a compelling product description for an e-commerce website.

Product Details:
- Name: <%= product_name %>
- Category: <%= category %>
- Key Features: <%= features.join(', ') %>
- Target Audience: <%= target_audience %>

Write a description that is engaging, SEO-friendly, and highlights the main benefits.
Length: <%= word_count %> words.
```

**Usage:**

```ruby
prompt = RailsPrompts.render_prompt('product_description', {
  product_name: "Smart Wireless Headphones",
  category: "Electronics",
  features: ["Noise cancellation", "30-hour battery", "Bluetooth 5.0"],
  target_audience: "Music enthusiasts and commuters",
  word_count: 150
})
```

### Example 3: Customer Support Response

**`app/prompts/support_response.md.erb`**

```erb
You are a friendly and helpful customer support agent for <%= company_name %>.

Customer Issue:
<%= customer_message %>

<% if previous_interactions.any? %>
Previous Interactions:
<% previous_interactions.each do |interaction| %>
- <%= interaction %>
<% end %>
<% end %>

Generate a professional and empathetic response that addresses the customer's concern.
Tone: <%= tone %>
```

**Usage:**

```ruby
prompt = RailsPrompts.render_prompt('support_response', {
  company_name: "Acme Corp",
  customer_message: "My order hasn't arrived yet",
  previous_interactions: ["Order placed 5 days ago", "Shipped 3 days ago"],
  tone: "friendly and apologetic"
})
```

## API Reference

### Module Methods

The `RailsPrompts` module provides the following methods:

#### `RailsPrompts.render_prompt(template_name, variables = {})`

Renders a prompt template with the provided variables.

- **Parameters:**
  - `template_name` (String): Name of the template file (without `.md.erb` extension)
  - `variables` (Hash): Key-value pairs to interpolate into the template
- **Returns:** (String) The rendered prompt content
- **Raises:** `ArgumentError` if the template file is not found

```ruby
prompt = RailsPrompts.render_prompt('my_template', { key: 'value' })
```

#### `RailsPrompts.available_prompts`

Lists all available prompt templates in the configured directory.

- **Returns:** (Array<String>) Array of template names without extensions

```ruby
templates = RailsPrompts.available_prompts
# => ["code_review", "summarize_text", "product_description"]
```

#### `RailsPrompts.prompts_dir`

Gets the current prompts directory path.

- **Returns:** (Pathname) Path to the prompts directory

```ruby
path = RailsPrompts.prompts_dir
# => #<Pathname:/path/to/app/prompts>
```

#### `RailsPrompts.prompts_dir=(path)`

Sets a custom prompts directory path.

- **Parameters:**
  - `path` (String|Pathname): Path to the custom prompts directory

```ruby
RailsPrompts.prompts_dir = Rails.root.join('custom', 'prompts')
```

## Architecture

RailsPrompts is organized as a module with the following structure:

```ruby
module RailsPrompts
  # Main service class containing all functionality
  class Service
    # Core methods: render_prompt, available_prompts, etc.
  end
  
  # Railtie for Rails integration
  class Railtie < Rails::Railtie
    # Automatic configuration and path setup
  end
  
  # Module-level delegation for convenient API
  # Allows: RailsPrompts.render_prompt(...)
  # Instead of: RailsPrompts::Service.render_prompt(...)
end
```

This design provides:
- Clean namespace organization
- Automatic Rails integration via Railtie
- Convenient API through delegation
- Easy extensibility for future features

## Best Practices

1. **Keep prompts version controlled**: Since prompts are just files, they're easy to track with git
2. **Use descriptive template names**: Name your files clearly (e.g., `generate_blog_title.md.erb`)
3. **Add comments in templates**: Document complex prompts or explain variable usage
4. **Test your prompts**: Create tests to ensure prompts render correctly with different inputs
5. **Use consistent naming**: Follow a naming convention (e.g., `action_context.md.erb`)
6. **Secure sensitive data**: Never hardcode API keys or secrets in templates
7. **Keep templates focused**: One prompt per file for better maintainability

## Error Handling

Rails Prompts will raise an `ArgumentError` if a template is not found:

```ruby
begin
  prompt = RailsPrompts.render_prompt('nonexistent_template', {})
rescue ArgumentError => e
  puts e.message
  # => "Prompt template 'nonexistent_template' not found at app/prompts/nonexistent_template.md.erb"
end
```

## Testing

### Configuring Test Directory

In your tests, you can configure a test-specific prompts directory:

```ruby
# In test_helper.rb or rails_helper.rb
RailsPrompts.prompts_dir = Rails.root.join('test', 'fixtures', 'prompts')
```

### RSpec Example

```ruby
# spec/services/prompt_service_spec.rb
RSpec.describe "RailsPrompts" do
  before do
    RailsPrompts.prompts_dir = Rails.root.join('spec', 'fixtures', 'prompts')
  end

  describe ".render_prompt" do
    it "renders a template with variables" do
      # spec/fixtures/prompts/test_prompt.md.erb contains:
      # Hello <%= name %>!
      
      result = RailsPrompts.render_prompt('test_prompt', name: 'World')
      expect(result).to eq("Hello World!")
    end

    it "raises error for missing template" do
      expect {
        RailsPrompts.render_prompt('nonexistent', {})
      }.to raise_error(ArgumentError, /not found/)
    end
  end

  describe ".available_prompts" do
    it "lists all available templates" do
      prompts = RailsPrompts.available_prompts
      expect(prompts).to include('test_prompt')
    end
  end
end
```

### Minitest Example

```ruby
# test/services/rails_prompts_test.rb
require 'test_helper'

class RailsPromptsTest < ActiveSupport::TestCase
  setup do
    RailsPrompts.prompts_dir = Rails.root.join('test', 'fixtures', 'prompts')
  end

  test "renders template with variables" do
    result = RailsPrompts.render_prompt('test_prompt', name: 'World')
    assert_equal "Hello World!", result
  end

  test "raises error for missing template" do
    assert_raises(ArgumentError) do
      RailsPrompts.render_prompt('nonexistent', {})
    end
  end

  test "lists available prompts" do
    prompts = RailsPrompts.available_prompts
    assert_includes prompts, 'test_prompt'
  end
end
```

## Advanced Usage

### Dynamic Template Selection

```ruby
# Select template based on user preference
template_name = user.prefers_detailed? ? 'detailed_summary' : 'brief_summary'
prompt = RailsPrompts.render_prompt(template_name, content: article.body)
```

### Chaining Prompts

```ruby
# First prompt: Generate outline
outline_prompt = RailsPrompts.render_prompt('generate_outline', topic: topic)
outline = ai_service.generate(outline_prompt)

# Second prompt: Expand outline into full content
content_prompt = RailsPrompts.render_prompt('expand_outline', outline: outline)
full_content = ai_service.generate(content_prompt)
```

### Using with Background Jobs

```ruby
# app/jobs/ai_content_job.rb
class AiContentJob < ApplicationJob
  queue_as :default

  def perform(article_id, template_name)
    article = Article.find(article_id)
    
    prompt = RailsPrompts.render_prompt(template_name, {
      title: article.title,
      content: article.body,
      keywords: article.keywords
    })
    
    result = OpenAI::Client.new.chat(
      parameters: {
        model: "gpt-4",
        messages: [{ role: "user", content: prompt }]
      }
    )
    
    article.update(ai_summary: result.dig("choices", 0, "message", "content"))
  end
end
```

### Conditional Logic in Templates

```erb
<%# app/prompts/smart_response.md.erb %>
You are a <%= role %> assistant.

<% if context == 'technical' %>
Please provide a detailed technical explanation with code examples.
<% elsif context == 'beginner' %>
Please explain in simple terms suitable for beginners.
<% else %>
Please provide a balanced explanation.
<% end %>

Question: <%= question %>

<% if include_examples %>
Include practical examples in your response.
<% end %>
```

## Testing

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.0

## Troubleshooting

### Common Issues

**Issue: Template not found error**
```
ArgumentError: Prompt template 'my_template' not found at app/prompts/my_template.md.erb
```
**Solution:** 
- Verify the file exists in the prompts directory
- Check the file has the correct `.md.erb` extension
- Ensure the template name matches the filename (case-sensitive)

**Issue: Variables not interpolating**
```erb
<%# Wrong - using HTML/JSX syntax %>
{variable}

<%# Correct - using ERB syntax %>
<%= variable %>
```

**Issue: Custom directory not working**
**Solution:** Ensure both configurations are set:
```ruby
# In config/application.rb
config.autoload_paths << Rails.root.join('lib', 'prompts')
config.after_initialize do
  RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')
end
```

**Issue: Changes not reflected in development**
**Solution:** Restart your Rails server after:
- Adding new template files
- Modifying the prompts directory configuration
- Changing autoload paths

## Frequently Asked Questions

**Q: Can I organize prompts in subdirectories?**
A: Currently, all templates must be in the root prompts directory. Subdirectory support is planned for a future release.

**Q: Can I use YAML front matter in templates?**
A: Not directly, but you can parse it manually:
```ruby
template_content = File.read(RailsPrompts.prompts_dir.join('my_template.md.erb'))
# Parse YAML front matter and process separately
```

**Q: How do I handle multiline variables?**
A: ERB handles multiline content automatically:
```erb
<%= long_text %>
```

**Q: Can I use partials or includes?**
A: Yes, using standard ERB:
```erb
<%# In main template %>
<%= ERB.new(File.read(RailsPrompts.prompts_dir.join('_partial.md.erb'))).result(binding) %>
```

**Q: Is there a performance impact?**
A: Templates are read from disk each time. For high-traffic applications, consider caching rendered prompts when variables don't change frequently.

## Roadmap

- [ ] Subdirectory support for organizing prompts
- [ ] Built-in template caching
- [ ] Template validation and linting
- [ ] CLI for managing prompts
- [ ] Support for multiple template formats (YAML, JSON)
- [ ] Template inheritance and composition
- [ ] Integration with popular AI service gems

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.0

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Riteshchaudhary710/rails_prompts

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Author

Ritesh Chaudhary (chaudharyritesh7100@gmail.com)
