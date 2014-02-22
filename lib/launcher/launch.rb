require 'aws-sdk'

module Launcher
  class Launch

    attr_accessor :messages

    attr_reader :name, :template, :discovered_parameters

    def initialize(name, template, params)
      @messages = []
      @name = name
      @template = template
      @discovered_parameters = params
    end

    def message(msg)
      @messages << msg
      @block.call(msg) if @block
    end

    def create(&block)
      @block = block
      create_cloudformation
    end

    def update(&block)
      @block = block
      update_cloudformation
    end

    def parameters
      {
        :parameters => filtered_parameters,
        :capabilities => ["CAPABILITY_IAM"]
      }
    end

    def filtered_parameters
      required = @template.non_defaulted_parameters
      @discovered_parameters.reject { |k| !required.include?(k) }
    end

    private

      def update_cloudformation
        message "Attempting to update stack with name #{@name}"
        cloudformation.stacks[@name].update parameters.merge(:template => @template.read)
      end

      def create_cloudformation
        message "Attempting to create stack with name #{@name}."
        cloudformation.stacks.create(@name, @template.read, parameters)
      end

      def cloudformation
        AWS::CloudFormation.new Launcher::Config::AWS.configuration
      end

      
  end
end