require 'launcher/template'
require 'launcher/stack'

module Launcher
  class CLI < Thor
    # Provides AWS Cloudformation Template based functionality.
    #
    # @example Validate an AWS template
    #   launcher template validate --template foobar.cloudformation
    class Template < Thor

      class_option :template, :type => :string, :aliases => "-t", :required => true

      desc "template validate", "Determine if a template is a valid AWS Cloudformation."
      # This CLI command attempts to validate a template to 
      # determine if it is a valid AWS Cloudformation. Note that if AWS Credentials are 
      # passed, the AWS Validation service will be used.
      # For more help on this command, use `launcher help update` from the command line.
      def validate
        template.message_handler do |msg, opts|
          Launcher::Log.send(opts[:type] || :info, msg)
        end
        if template.valid?
          template.message "The template is valid.", :type => :ok
        else
          template.message "The template is invalid", :type => :error
        end
      end

      private

        def template
          Launcher::Template.new(options[:template])
        end

    end
  end
end