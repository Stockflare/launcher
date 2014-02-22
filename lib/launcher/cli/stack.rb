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
      class_option :update, :type => :boolean, :default => false

      desc "create", "Launch a new AWS Cloudformation template using discoverable parameters"
      method_option :name, :type => :string, :aliases => "-n", :required => true
      method_option :template, :type => :string, :aliases => "-t", :required => true
      def create
        cloudformation(:create)
      end

      desc "update", "Updates a pre-existing Cloudformation template."
      method_option :name, :type => :string, :aliases => "-n", :required => true
      method_option :template, :type => :string, :aliases => "-t", :required => true
      def update
        cloudformation(:update)
      end

      private

        def cloudformation(op)
          Launcher::Config(options)
          discovered = Launcher::Parameters.new(options[:params] || {}).all
          template = Launcher::Template.new(options[:template])
          Launcher::Launch.new(options[:name], template, discovered).send(op) do |message|
            Launcher::Log.info message
          end
        end

    end
  end
end