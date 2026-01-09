# frozen_string_literal: true

require_relative 'rails_prompts/version'
require_relative 'rails_prompts/railtie' if defined?(Rails::Railtie)

module RailsPrompts
  ##
  # Service class for managing AI prompts stored in markdown files with ERB interpolation.
  # This centralizes prompt management and makes them easier to review and modify.

  class Service
    class << self
      def prompts_dir=(path)
        @prompts_dir = path.is_a?(Pathname) ? path : Pathname.new(path)
      end

      def prompts_dir
        @prompts_dir ||= defined?(Rails) && Rails.root ? Rails.root.join('app', 'prompts') : Pathname.new('app/prompts')
      end

      # Renders a prompt template with the provided variables
      # @param template_name [String] The name of the template file (without .md.erb extension)
      # @param variables [Hash] Variables to be interpolated into the template
      # @return [String] The rendered prompt
      def render_prompt(template_name, variables = {})

        template_path = prompts_dir.join("#{template_name}.md.erb")

        unless File.exist?(template_path)
          raise ArgumentError, "Prompt template '#{template_name}' not found at #{template_path}"
        end

        template_content = File.read(template_path)

        # Create an ERB template with the content
        erb_template = ERB.new(template_content, trim_mode: '-')

        # Create a binding with the provided variables
        binding_context = create_binding_context(variables)

        # Render the template
        erb_template.result(binding_context)
      end

      # Lists all available prompt templates
      # @return [Array<String>] Array of template names (without extensions)
      def available_prompts
        Dir.glob(prompts_dir.join('*.md.erb')).map do |file|
          File.basename(file, '.md.erb')
        end
      end

      private

      # Creates a binding context with the provided variables. This method uses an
      # anonymous Struct to create a clean, isolated binding
      # @param variables [Hash] Variables to be made available in the template
      # @return [Binding] A binding object with the variables defined
      def create_binding_context(variables)
        # Return an empty binding if no variables are provided
        return binding if variables.empty?

        # Create an anonymous Struct with keys from the variables hash,
        # instantiate it with the values, and return its binding.
        Struct.new(*variables.keys.map(&:to_sym)).new(*variables.values).instance_eval { binding }
      end
    end
  end

  # Keep backward compatibility by delegating to Service
  class << self
    def method_missing(method, *args, &block)
      if Service.respond_to?(method)
        Service.send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      Service.respond_to?(method, include_private) || super
    end
  end
end
