# frozen_string_literal: true

require 'rails/generators'

module RailsPrompts
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Creates the app/prompts directory and sample prompt template'

      def create_prompts_directory
        empty_directory 'app/prompts'
        create_file 'app/prompts/.keep'
      end

      def create_sample_prompt
        create_file 'app/prompts/sample.md.erb', <<~PROMPT
          You are a helpful AI assistant.

          User's question:
          ---
          <%= question %>
          ---

          Please provide a clear and concise answer.
        PROMPT
      end

      def show_readme
        say "\n"
        say "✅ RailsPrompts has been installed!", :green
        say "\n"
        say "The app/prompts directory has been created with a sample template."
        say "Since you're using app/prompts, no additional configuration is needed!"
        say "\n"
        say "To use a custom location (like lib/prompts), add this to config/application.rb:"
        say "  config.autoload_paths << Rails.root.join('lib', 'prompts')"
        say "  RailsPrompts.prompts_dir = Rails.root.join('lib', 'prompts')"
        say "\n"
        say "Usage example:"
        say "  prompt = RailsPrompts.render_prompt('sample', question: 'What is Ruby?')"
        say "\n"
      end
    end
  end
end
