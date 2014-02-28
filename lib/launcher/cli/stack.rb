require 'launcher/template'
require 'launcher/stack'

module Launcher
  class CLI < Thor
    # Provides AWS Cloudformation Stack based functionality.
    #
    # @example Create a new stack
    #   launcher stack create --name foo --template foobar.cloudformation --params foo:bar
    #
    # @example Updating a pre-existing stack
    #   launcher stack update --name foo --template new_foobar.cloudformation
    class Stack < Thor

      class_option :params, :type => :hash, :aliases => "-p"

      desc "stack create", "Launch a new AWS Cloudformation template using discoverable parameters"
      method_option :name, :type => :string, :aliases => "-n"
      method_option :template, :type => :string, :aliases => "-t", :required => true
      # This CLI command launches a new Cloudformation given the provided arguments passed to it.
      # For more help on this command, use `launcher help create` from the command line.
      def create
        cloudformation(:create)
      end

      desc "stack update", "Updates a pre-existing Cloudformation template."
      method_option :name, :type => :string, :aliases => "-n"
      method_option :config_files, :type => :array, :aliases => "-c"
      method_option :template, :type => :string, :aliases => "-t", :required => true
      # This CLI command updates an pre-existing AWS Cloudformation template, updating parameters.
      # For more help on this command, use `launcher help update` from the command line.
      def update
        cloudformation(:update)
      end

      private

        def cloudformation(op)
          Launcher::Stack.new(name, template, discovered).send(op) do |message, opts|
            Launcher::Log.send(opts[:type] || :info, message)
          end
        end

        def discovered
          Launcher::Parameters.new(options[:params] || {}).all
        end

        def template
          template = Launcher::Template.new(options[:template])
        end

        def name 
          options[:name] || template.name
        end

    end
  end
end