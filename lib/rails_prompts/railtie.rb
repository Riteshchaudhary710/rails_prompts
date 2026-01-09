# frozen_string_literal: true

require 'rails/railtie'

module RailsPrompts
  class Railtie < Rails::Railtie
    # Automatically add app/prompts to autoload paths if it exists
    initializer 'rails_prompts.configure_autoload_paths', before: :set_autoload_paths do |app|
      prompts_path = app.root.join('app', 'prompts')

      if prompts_path.exist?
        # Add app/prompts to autoload paths
        app.config.autoload_paths << prompts_path.to_s

        # Also add to eager load paths in production
        app.config.eager_load_paths << prompts_path.to_s
      end
    end

    # Set the default prompts directory
    config.after_initialize do
      RailsPrompts.prompts_dir = Rails.root.join('app', 'prompts') if defined?(Rails)
    end

    # Add rake tasks
    rake_tasks do
      load 'rails_prompts/tasks/install.rake'
    end
  end
end
