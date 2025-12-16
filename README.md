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

## Usage

### 1. Create Your Prompts Directory

By default, Rails Prompts looks for prompt templates in `app/prompts/`. Create this directory:

```bash
mkdir -p app/prompts
```

### 2. Create Prompt Templates

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

### 3. Render Prompts in Your Application

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

### 4. List Available Prompts

You can get a list of all available prompt templates:

```ruby
RailsPrompts.available_prompts
# => ["summarize_text", "generate_title", "code_review"]
```

### 5. Configure Custom Prompts Directory (Optional)

If you want to store prompts in a different directory:

```ruby
# In config/initializers/rails_prompts.rb
RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')
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

## Best Practices

1. **Keep prompts version controlled**: Since prompts are just files, they're easy to track with git
2. **Use descriptive template names**: Name your files clearly (e.g., `generate_blog_title.md.erb`)
3. **Add comments in templates**: Document complex prompts or explain variable usage
4. **Test your prompts**: Create tests to ensure prompts render correctly with different inputs
5. **Organize by feature**: Use subdirectories if you have many prompts (coming soon)

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

In your tests, you can configure a test-specific prompts directory:

```ruby
# In test_helper.rb or rails_helper.rb
RailsPrompts.prompts_dir = Rails.root.join('test', 'fixtures', 'prompts')
```

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.0

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Riteshchaudhary710/rails_prompts

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Author

Ritesh Chaudhary (chaudharyritesh7100@gmail.com)
