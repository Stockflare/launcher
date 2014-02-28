module Launcher
  # The Launcher::Stacks class provides wrapper and helper methods for 
  # extracting information and easily enumerating over Cloudformations 
  # without the need to code around pagination/limiting.
  class Stacks

    include Launcher::Message

    attr_reader :all

    def initialize
      if aws_configured?
        @all = stacks
      else
        message "AWS is not configured.", :type => :fatal
      end
    end

    # Loop over every existing AWS Cloudformation. This method
    # wraps pagination into a single each call.
    #
    # @example Looping over each Cloudformation
    #   Launcher::Stacks.new.each do |stack|
    #     puts stack.name
    #   end
    def each(&block)
      @all.each_batch { |batch| batch.each { |s| yield s } }
    end

    # Return a status Array for each Cloudformation currently on AWS.
    # The status for each Stack is returned as a Hash.
    # You can either iterate over each status by passing in a block, or
    # return the array of all statuses.
    #
    # @example Getting the name and status for each Cloudformation
    #   Launcher::Stacks.new.all_statuses do |status|
    #     puts "#{status[:name]} is in state #{status[:status]}"
    #   end
    #
    # @return [Array] array of Hash objects containing information about the status of each stack.
    def all_statuses(&block)
      statuses = []
      each { |stack| statuses << status(stack) }
      statuses.each &block if block
      return statuses
    end

    private

      def status(stack)
        {
          :name => stack.name,
          :status => stack.status,
          :updated_at => stack.last_updated_time || stack.creation_time,
          :status_reason => stack.status_reason
        }
      end

      def stacks
        cloudformation.stacks
      end

      def cloudformation
        AWS::CloudFormation.new
      end

      def aws_configured?
        Launcher::Config::AWS.configured?
      end

  end
end