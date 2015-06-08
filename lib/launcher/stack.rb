require 'aws-sdk'

module Launcher
  # The {Launcher::Stack} class handles communicating with the AWS Cloudformation API to
  # create, update, delete and show the current Cloudformations based upon the AWS Access
  # credentials that are provided.
  #
  # @example Launching a new Cloudformation via the CLI
  #   launcher stack create --name foo --template path/to/foo.cloudformation
  #
  # @example Launching a new Cloudformation programatically
  #   template = Launcher::Template.new(options[:template])
  #   stack = Launcher::Stack.new("foo", template) do |message|
  #     #output event messages as they happen
  #     puts message
  #   end
  #   stack.create
  class Stack

    CAPABILITIES = %w{CAPABILITY_IAM}

    include Launcher::Message

    attr_reader :name, :template, :discovered_parameters

    attr_accessor :events

    # Creates a new instance of {Launcher::Stack}. Setting the template name,
    # the template and setting the discovered parameters to be passed to the
    # Cloudformation.
    def initialize(name, template, params = {}, &block)
      @name = name
      @template = template
      @discovered_parameters = params
      @events = []
      message_handler &block if block
    end

    # Creates a new AWS Cloudformation using a name, template and an
    # optional hash of parameters to be used by the Cloudformation.
    #
    # @note All Cloudformations have the CAPABILITY_IAM passed into them. This helps to
    #       ensure the simplicity of launching or updating Cloudformations.
    #
    # @example Creating a new Cloudformation programatically
    #   template = Launcher::Template.new(options[:template])
    #   stack = Launcher::Stack.new("foo", template) do |message|
    #     #output event messages as they happen
    #     puts message
    #   end
    #   stack.create
    def create
      with_client &method(:create_cloudformation) if valid?
    end

    # Updates a pre-existing AWS Cloudformation to use an adjusted template
    # or an updated set of parameters.
    #
    # @note All Cloudformations have the CAPABILITY_IAM passed into them. This helps to
    #       ensure the simplicity of launching or updating Cloudformations.
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
      with_client &method(:update_cloudformation) if valid?
    end

    # Delete a pre-existing cloudformation given the name that it has been
    # initialized with.
    def delete
      with_client &method(:delete_cloudformation)
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
      with_client do |client|
        response = client.estimate_template_cost({
          template_body: template.read,
          parameters: parameters
        })
        message response[:url], type: :ok
      end if valid?
    end

    # The parameters array that will be passed into the Cloudformation during
    # creation or update. The :parameters key contains a list of filtered parameters
    # that are a subset of all the discoverable environment parameters, that are
    # neither defaulted or provided via the CLI.
    #
    #
    # @return [Hash] The parameter object that will be passed into the Cloudformation.
    def parameters
      filtered_parameters.to_a.collect do |param|
        { parameter_key: param[0], parameter_value: param[1] }
      end
    end

    # Hash of the filtered parameter set for use within the Cloudformation. This
    # single depth, key => value Hash is the list of parameters that are not defaulted
    # and cannot be discovered.
    #
    # @return [Hash] Set of parameters that cannot be discovered and will be passed into the Cloudformation.
    def filtered_parameters
      required = template.non_defaulted_parameters
      discovered_parameters.reject { |k| !required.include?(k) }
    end

    # An array of required parameter keys that are missing from the Cloudformation. If a key
    # is present within this array, it means that the Cloudformation will not successfully launch.
    #
    # @return [Array] List of keys that are missing from the AWS Cloudformation.
    def missing_parameters
      template.non_defaulted_parameters.keys - filtered_parameters.keys
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

      valid = template.valid?
      template.messages { |m,o| message m,o } unless valid

      valid = !missing_parameters?
      missing_parameters.each { |m| message "The parameter [#{m.to_s}] is required.", type: :fatal } unless valid

      return valid
    end

    private

    def delete_cloudformation(client)
      message "Deleting stack #{name}..."
      client.delete_stack({ stack_name: name })
    end

    def update_cloudformation(client)
      message "Updating stack #{name}..."
      client.update_stack(payload).stack_id
      client.wait_until :stack_update_complete, &method(:waiter)
    end

    def create_cloudformation(client)
      message "Creating stack #{name}..."
      client.create_stack(payload).stack_id
      client.wait_until :stack_create_complete, &method(:waiter)
    end

    def payload
      {
        stack_name: name,
        template_body: template.read,
        capabilities: CAPABILITIES,
        parameters: parameters
      }
    end

    def with_client
      yield client
      on_wait if events.length
    rescue => e
      message e.message, type: :fatal
    else
      message "Completed successfully.", type: :ok
    end

    def waiter(waiter)
      waiter.delay = 5
      on_wait
    end

    def on_wait
      new_events = client.describe_stack_events(stack_name: name)[:stack_events]
      if !events.empty? && diff = new_events.length - events.length
        new_events.sort_by(&:timestamp)[0...diff].each &method(:event_handler)
      end
      self.events = new_events
    end

    def event_handler(event)
      resource = event.logical_resource_id
      status = event.resource_status
      msg = event.resource_status_reason
      str = "[#{resource}] [#{status}]: #{msg}"
      message [resource, status, msg], type: :info
    end

    def client
      Launcher.cloudformation_client
    end

  end
end
