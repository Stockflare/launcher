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

      def initialize(*args)
        super
        Launcher::Config(options)
      end

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

      desc "stack simulate", "Simulates the creation or update of an AWS Cloudformation."
      method_option :template, :type => :string, :aliases => "-t", :required => true
      # This CLI command simulates and outputs various information that would be used to
      # create or update an AWS Cloudformation.
      def simulate
        stack = Launcher::Stack.new(name, template, discovered, &method(:to_log))
        if stack.valid?
          to_log "Stack would be launched with ID \"#{name}\"", :ok

          discovered = stack.filtered_parameters
          unless discovered.empty?
            to_log "With discovered parameters:", :ok
            rows = []
            discovered.each { |k, v| rows << [k, v] }
            to_log "\n", Terminal::Table.new(:headings => ["Key", "Value"], :rows => rows), :ok
          else
            to_log "No discoverable parameters found.", :warn
          end

          defaulted = template.defaulted_parameters
          unless defaulted.empty?
            to_log "With defaulted parameters:", :ok
            rows = []
            defaulted.each { |k, v| rows << [k, v[:Default]] }
            to_log "\n", Terminal::Table.new(:headings => ["Key", "Value"], :rows => rows), :ok
          else
            to_log "No defaulted parameters found.", :warn
          end
        end

      end

      private

        def cloudformation(op)
          Launcher::Stack.new(name, template, discovered, &method(:to_log)).send(op)
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

        def to_log(message, opts = {})
          opts = { type: opts } if opts.is_a? Symbol
          Launcher::Log.send(opts[:type] || :info, message)
        end

    end
  end
end
