# frozen_string_literal: true

namespace :rails_prompts do
  desc 'Install RailsPrompts: creates app/prompts directory with sample template'
  task :install do
    require 'fileutils'

    prompts_dir = File.join(Dir.pwd, 'app', 'prompts')

    # Create the directory
    FileUtils.mkdir_p(prompts_dir)
    puts "✅ Created directory: app/prompts"

    # Create .keep file
    keep_file = File.join(prompts_dir, '.keep')
    FileUtils.touch(keep_file)

    # Create sample template
    sample_file = File.join(prompts_dir, 'sample.md.erb')
    File.write(sample_file, <<~PROMPT)
      You are a helpful AI assistant.

      User's question:
      ---
      <%= question %>
      ---

      Please provide a clear and concise answer.
    PROMPT

    puts "✅ Created sample template: app/prompts/sample.md.erb"
    puts "\n"
    puts "🎉 RailsPrompts has been installed!"
    puts "\n"
    puts "Since you're using app/prompts, no additional configuration is needed!"
    puts "The directory is automatically added to Rails autoload paths."
    puts "\n"
    puts "To use a custom location (like lib/prompts), add this to config/application.rb:"
    puts "  config.autoload_paths << Rails.root.join('lib', 'prompts')"
    puts "  RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')"
    puts "\n"
    puts "Usage example:"
    puts "  prompt = RailsPrompts.render_prompt('sample', question: 'What is Ruby?')"
    puts "\n"
  end
end
