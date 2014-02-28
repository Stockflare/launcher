require 'aws-sdk'

module Launcher
  # The {Launcher::Stack} class handles communicating with the AWS Cloudformation API to
  # create, update, delete and show the current Cloudformations based upon the AWS Access
  # credentials that are provided.
  #
  # @example Creating a new Cloudformation via the CLI
  #   launcher stack create --name foo --template path/to/foo.cloudformation
  #
  # @example Creating a new Cloudformation programatically
  #   template = Launcher::Template.new(options[:template])
  #   stack = Launcher::Stack.new("foo", template) do |message|
  #     #output event messages as they happen
  #     puts message
  #   end
  #   stack.create
  class Stack

    include Launcher::Message

    attr_reader :name, :template, :discovered_parameters

    # Creates a new instance of {Launcher::Stack}. Setting the template name,
    # the template and setting the discovered parameters to be passed to the
    # Cloudformation.
    def initialize(name, template, params = {}, &block)
      @name = name
      @template = template
      @discovered_parameters = params
      message_handler &block if block
    end

    # Creates a new AWS Cloudformation using a name, template and an
    # optional hash of parameters to be used by the Cloudformation.
    #
    # @example Creating a new Cloudformation programatically
    #   template = Launcher::Template.new(options[:template])
    #   stack = Launcher::Stack.new("foo", template) do |message|
    #     #output event messages as they happen
    #     puts message
    #   end
    #   stack.create
    def create
      create_cloudformation if valid?
    end

    # Updates a pre-existing AWS Cloudformation to use an adjusted template
    # or an updated set of parameters. 
    #
    # @example Updating a cloudformation via the CLI
    #   launcher stack update --name foo --template path/to/my/updated/foo.cloudformation --params ImageId:ami-31231a
    #
    # @example Creating a new Cloudformation programatically
    #   template = Launcher::Template.new(options[:template])
    #   stack = Launcher::Stack.new("foo", template) do |message|
    #     #output event messages as they happen
    #     puts message
    #   end
    #   stack.update
    def update
      update_cloudformation if valid?
    end

    # Delete a pre-existing cloudformation given the name that it has been
    # initialized with.
    def delete
      delete_cloudformation
    end

    # Retrieves the URL from the Amazon API that determines the estimated cost for the
    # loaded cloudformation template.
    #
    # @example Retrieving the URL to estimate the template cost.
    #   template = Launcher::Template.new(options[:template])
    #   stack = Launcher::Stack.new("foo", template)
    #   url = stack.cost
    #
    # @return [String] the url to estimate the template cost.
    def cost
      if aws_configured? && valid?
        url = cloudformation.estimate_template_cost(@template.read, filtered_parameters)
        message url, :type => :ok
        return url
      else
        message "AWS not configured.", :type => :fatal
      end
    end

    # The parameters array that will be passed into the Cloudformation during 
    # creation or update. The :parameters key contains a list of filtered parameters
    # that are a subset of all the discoverable environment parameters, that are
    # neither defaulted or provided via the CLI.

    # @note All Cloudformations have the CAPABILITY_IAM passed into them. This helps to
    #       ensure the simplicity of launching or updating Cloudformations.
    #
    # @return [Hash] The parameter object that will be passed into the Cloudformation.
    def parameters
      {
        :parameters => filtered_parameters,
        :capabilities => ["CAPABILITY_IAM"]
      }
    end

    # Hash of the filtered parameter set for use within the Cloudformation. This
    # single depth, key => value Hash is the list of parameters that are not defaulted
    # and cannot be discovered.
    #
    # @return [Hash] Set of parameters that cannot be discovered and will be passed into the Cloudformation.
    def filtered_parameters
      required = @template.non_defaulted_parameters
      @discovered_parameters.reject { |k| !required.include?(k) }
    end

    # An array of required parameter keys that are missing from the Cloudformation. If a key
    # is present within this array, it means that the Cloudformation will not successfully launch.
    #
    # @return [Array] List of keys that are missing from the AWS Cloudformation.
    def missing_parameters
      @template.non_defaulted_parameters.keys - filtered_parameters.keys
    end

    # Determines if the Cloudformation is requiring parameters that have not been discovered
    # and/or are missing. 
    #
    # @return [Boolean] True if parameters are missing, false otherwise.
    def missing_parameters?
      missing_parameters.length > 0
    end

    # Validates the parameters that have been passed into the Stack class upon initialization
    # to determine if the Cloudformation will update or create successfully. This method
    # will attempt to provide helpful validation error messages if the options are not valid.
    #
    # @return [Boolean] True if the stack is valid and can be launched, false otherwise.
    def valid?
      #presume everything is valid
      valid = true

      valid = @template.valid?
      @template.messages { |m,o| message m,o } unless valid

      valid = !missing_parameters?
      missing_parameters.each { |m| message "The parameter [#{m.to_s}] is required.", :type => :fatal } unless valid

      return valid
    end

    private

      def delete_cloudformation
        message "Attempting to delete stack with name #{@name}"
        with_cloudformation { |cf| cf.stacks[@name].delete }
      end

      def update_cloudformation
        message "Attempting to update stack with name #{@name}"
        with_cloudformation { |cf| cf.stacks[@name].update parameters.merge(:template => @template.read) }
      end

      def create_cloudformation
        message "Attempting to create stack with name #{@name}."
        with_cloudformation { |cf| cf.stacks.create(@name, @template.read, parameters) }
      end

      def with_cloudformation(&block)
        begin
          if aws_configured?
            block.call(cloudormation)
          else
            raise new Error "AWS not configured."
          end
        rescue => e
          message e.message, :type => :fatal
        end
      end

      def aws_configured?
        Launcher::Config::AWS.configured?
      end

      def cloudformation
        AWS::CloudFormation.new
      end
      
  end
end