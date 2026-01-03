# frozen_string_literal: true

require 'spec_helper'
require 'rails_prompts'
require 'tmpdir'
require 'fileutils'

RSpec.describe RailsPrompts do
  describe '.method_missing' do
    it 'delegates to Service class' do
      allow(RailsPrompts::Service).to receive(:available_prompts).and_return(['test'])
      expect(described_class.available_prompts).to eq(['test'])
    end

    it 'raises NoMethodError for undefined methods' do
      expect { described_class.undefined_method }.to raise_error(NoMethodError)
    end
  end

  describe '.respond_to_missing?' do
    it 'returns true for Service methods' do
      expect(described_class.respond_to?(:available_prompts)).to be true
      expect(described_class.respond_to?(:render_prompt)).to be true
    end

    it 'returns false for undefined methods' do
      expect(described_class.respond_to?(:undefined_method)).to be false
    end
  end
end

RSpec.describe RailsPrompts::Service do
  let(:temp_dir) { Dir.mktmpdir }

  before do
    described_class.prompts_dir = temp_dir
  end

  after do
    FileUtils.rm_rf(temp_dir)
  end

  describe '.prompts_dir' do
    context 'when Rails is defined' do
      before do
        stub_const('Rails', Class.new do
          def self.root
            Pathname.new('/fake/rails/root')
          end
        end)
      end

      it 'returns Rails.root/app/prompts by default' do
        # Reset the instance variable to test default behavior
        described_class.instance_variable_set(:@prompts_dir, nil)
        expect(described_class.prompts_dir.to_s).to eq('/fake/rails/root/app/prompts')
      end
    end

    context 'when Rails is not defined' do
      before do
        hide_const('Rails')
        described_class.instance_variable_set(:@prompts_dir, nil)
      end

      it 'returns app/prompts as a Pathname' do
        expect(described_class.prompts_dir).to eq(Pathname.new('app/prompts'))
      end
    end

    it 'can be set with prompts_dir=' do
      custom_dir = '/custom/prompts'
      described_class.prompts_dir = custom_dir
      expect(described_class.prompts_dir).to eq(Pathname.new(custom_dir))
    end
  end

  describe '.render_prompt' do
    let(:template_name) { 'test_template' }
    let(:template_path) { File.join(temp_dir, "#{template_name}.md.erb") }

    context 'when template exists' do
      context 'with simple content' do
        before do
          File.write(template_path, 'Hello, World!')
        end

        it 'renders the template without variables' do
          result = described_class.render_prompt(template_name)
          expect(result).to eq('Hello, World!')
        end
      end

      context 'with ERB interpolation' do
        before do
          File.write(template_path, 'Hello, <%= name %>!')
        end

        it 'renders the template with variables' do
          result = described_class.render_prompt(template_name, name: 'Alice')
          expect(result).to eq('Hello, Alice!')
        end

        it 'works with string keys' do
          result = described_class.render_prompt(template_name, 'name' => 'Bob')
          expect(result).to eq('Hello, Bob!')
        end
      end

      context 'with multiple variables' do
        before do
          File.write(template_path, 'Hello, <%= name %>! You are <%= age %> years old.')
        end

        it 'renders with multiple variables' do
          result = described_class.render_prompt(template_name, name: 'Charlie', age: 30)
          expect(result).to eq('Hello, Charlie! You are 30 years old.')
        end
      end

      context 'with ERB trim mode' do
        before do
          File.write(template_path, "Line 1\n<% if true -%>\nLine 2\n<% end -%>\nLine 3")
        end

        it 'applies trim mode correctly' do
          result = described_class.render_prompt(template_name)
          expect(result).to eq("Line 1\nLine 2\nLine 3")
        end
      end

      context 'with complex ERB logic' do
        before do
          content = <<~ERB
            # User Report

            Name: <%= name %>
            <% if admin %>
            Role: Administrator
            <% else %>
            Role: User
            <% end %>

            Items:
            <% items.each do |item| %>
            - <%= item %>
            <% end %>
          ERB
          File.write(template_path, content)
        end

        it 'renders complex templates with loops and conditionals' do
          result = described_class.render_prompt(
            template_name,
            name: 'Dave',
            admin: true,
            items: ['Item 1', 'Item 2', 'Item 3']
          )

          expect(result).to include('Name: Dave')
          expect(result).to include('Role: Administrator')
          expect(result).to include('- Item 1')
          expect(result).to include('- Item 2')
          expect(result).to include('- Item 3')
        end

        it 'handles non-admin users' do
          result = described_class.render_prompt(
            template_name,
            name: 'Eve',
            admin: false,
            items: []
          )

          expect(result).to include('Name: Eve')
          expect(result).to include('Role: User')
          expect(result).not_to include('Role: Administrator')
        end
      end

      context 'with empty variables hash' do
        before do
          File.write(template_path, 'No variables needed')
        end

        it 'renders without error' do
          result = described_class.render_prompt(template_name, {})
          expect(result).to eq('No variables needed')
        end
      end
    end

    context 'when template does not exist' do
      it 'raises ArgumentError with helpful message' do
        expect {
          described_class.render_prompt('nonexistent')
        }.to raise_error(ArgumentError, /Prompt template 'nonexistent' not found/)
      end

      it 'includes the full path in error message' do
        expect {
          described_class.render_prompt('missing')
        }.to raise_error(ArgumentError, /#{temp_dir}/)
      end
    end

    context 'with ERB syntax errors' do
      before do
        File.write(template_path, 'Hello <% if true %>')
      end

      it 'raises an error during rendering' do
        expect {
          described_class.render_prompt(template_name, name: 'Test')
        }.to raise_error(SyntaxError)
      end
    end
  end

  describe '.available_prompts' do
    context 'when prompts directory is empty' do
      it 'returns an empty array' do
        expect(described_class.available_prompts).to eq([])
      end
    end

    context 'when prompts directory has templates' do
      before do
        File.write(File.join(temp_dir, 'template1.md.erb'), 'Content 1')
        File.write(File.join(temp_dir, 'template2.md.erb'), 'Content 2')
        File.write(File.join(temp_dir, 'template3.md.erb'), 'Content 3')
      end

      it 'returns all template names without extensions' do
        prompts = described_class.available_prompts
        expect(prompts).to contain_exactly('template1', 'template2', 'template3')
      end
    end

    context 'when directory has mixed file types' do
      before do
        File.write(File.join(temp_dir, 'valid_template.md.erb'), 'Valid')
        File.write(File.join(temp_dir, 'not_a_template.txt'), 'Text')
        File.write(File.join(temp_dir, 'also_not.md'), 'Markdown')
        File.write(File.join(temp_dir, 'README.md'), 'Readme')
      end

      it 'returns only .md.erb files' do
        expect(described_class.available_prompts).to eq(['valid_template'])
      end
    end

    context 'when directory has nested structure' do
      before do
        File.write(File.join(temp_dir, 'top_level.md.erb'), 'Top')
        FileUtils.mkdir_p(File.join(temp_dir, 'nested'))
        File.write(File.join(temp_dir, 'nested', 'nested_template.md.erb'), 'Nested')
      end

      it 'only returns top-level templates' do
        expect(described_class.available_prompts).to eq(['top_level'])
      end
    end
  end

  describe '.create_binding_context' do
    it 'is a private method' do
      expect(described_class.private_methods).to include(:create_binding_context)
    end

    context 'with empty variables' do
      it 'returns a binding' do
        result = described_class.send(:create_binding_context, {})
        expect(result).to be_a(Binding)
      end
    end

    context 'with variables' do
      it 'creates a binding with accessible variables' do
        binding_context = described_class.send(:create_binding_context, name: 'Test', age: 25)

        # Test that variables are accessible in the binding
        result = eval('name', binding_context)
        expect(result).to eq('Test')

        result = eval('age', binding_context)
        expect(result).to eq(25)
      end

      it 'converts string keys to symbols' do
        binding_context = described_class.send(:create_binding_context, 'name' => 'StringKey')
        result = eval('name', binding_context)
        expect(result).to eq('StringKey')
      end

      it 'handles various data types' do
        binding_context = described_class.send(:create_binding_context, {
          string: 'text',
          number: 42,
          array: [1, 2, 3],
          hash: { key: 'value' },
          boolean: true,
          nil_value: nil
        })

        expect(eval('string', binding_context)).to eq('text')
        expect(eval('number', binding_context)).to eq(42)
        expect(eval('array', binding_context)).to eq([1, 2, 3])
        expect(eval('hash', binding_context)).to eq({ key: 'value' })
        expect(eval('boolean', binding_context)).to be true
        expect(eval('nil_value', binding_context)).to be_nil
      end
    end
  end

  describe 'integration tests' do
    before do
      # Create multiple templates for integration testing
      File.write(File.join(temp_dir, 'greeting.md.erb'), 'Hello, <%= name %>!')
      File.write(File.join(temp_dir, 'report.md.erb'), <<~ERB)
        # Report for <%= user %>

        Status: <%= status %>
        Date: <%= date %>
      ERB
    end

    it 'can list and render multiple templates' do
      prompts = described_class.available_prompts
      expect(prompts).to include('greeting', 'report')

      greeting_result = described_class.render_prompt('greeting', name: 'Integration Test')
      expect(greeting_result).to eq('Hello, Integration Test!')

      report_result = described_class.render_prompt('report', {
        user: 'Tester',
        status: 'Complete',
        date: '2025-12-29'
      })
      expect(report_result).to include('Report for Tester')
      expect(report_result).to include('Status: Complete')
      expect(report_result).to include('Date: 2025-12-29')
    end

    it 'maintains isolation between different renders' do
      result1 = described_class.render_prompt('greeting', name: 'First')
      result2 = described_class.render_prompt('greeting', name: 'Second')

      expect(result1).to eq('Hello, First!')
      expect(result2).to eq('Hello, Second!')
    end
  end
end
