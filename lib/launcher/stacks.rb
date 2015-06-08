module Launcher
  # The Launcher::Stacks class provides wrapper and helper methods for
  # extracting information and easily enumerating over Cloudformations
  # without the need to code around pagination/limiting.
  class Stacks

    include Launcher::Message

    attr_reader :all

    # Loop over every existing AWS Cloudformation. This method
    # wraps pagination into a single each call.
    #
    # @example Looping over each Cloudformation
    #   Launcher::Stacks.new.each do |stack|
    #     puts stack.name
    #   end
    def each(&block)
      stacks.each { |stack| yield stack }
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
        :name => stack.stack_name,
        :status => stack.stack_status,
        :updated_at => stack.last_updated_time || stack.creation_time,
        :status_reason => stack.stack_status_reason
      }
    end

    # Retrieves an Array of stacks containing
    # an enumerable list of pre-existing Cloudformation stacks that have been
    # detected using the credentials defined.
    #
    # @return [Array] array of existing stacks.
    def stacks
      client.describe_stacks[:stacks]
    end

    def client
      Launcher.cloudformation_client
    end

  end
end
