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
      class_option :name, :type => :string, :aliases => "-n"
      class_option :config_files, :type => :array, :aliases => "-c"

      desc "stack create", "Launch a new AWS Cloudformation template using discoverable parameters"
      method_option :template, :type => :string, :aliases => "-t", :required => true
      # This CLI command launches a new Cloudformation given the provided arguments passed to it.
      # For more help on this command, use `launcher help create` from the command line.
      def create
        cloudformation(:create)
      end

      desc "stack update", "Updates a pre-existing Cloudformation template."
      method_option :template, :type => :string, :aliases => "-t", :required => true
      # This CLI command updates an pre-existing AWS Cloudformation template, updating parameters.
      # For more help on this command, use `launcher help update` from the command line.
      def update
        cloudformation(:update)
      end

      desc "stack delete", "Delete a pre-existing Cloudformation template."
      method_option :name, :type => :string, :requied => true, :aliases => "-n"
      # This CLI command commences the deletion of a pre-existing AWS Cloudformation
      # For more help on this command, use `launcher help update` from the command line.
      def delete
        cloudformation(:delete)
      end

      desc "stack cost", "Retrieves a URL that provides an estimate cost this template."
      method_option :template, :type => :string, :aliases => "-t", :required => true
      # This CLI command retrieves a URL from the AWS API that provides an estimate cost for the template.
      # For more help on this command, use `launcher help update` from the command line.
      def cost
        cloudformation(:cost)
      end

      private

        def cloudformation(op)
          stack = Launcher::Stack.new(name, template, discovered) { |message, opts|
            Launcher::Log.send(opts[:type] || :info, message)
          }
          stack.send(op)
        end

        def discovered
          Launcher::Parameters.new
        end

        def template
          @template ||= Launcher::Template.new(options[:template]) if options[:template]
        end

        def name 
          options[:name] || template.name
        end

    end
  end
end