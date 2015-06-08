require "launcher/version"
require "launcher/config"

# The Launcher module provides a mix of helper classes aimed at providing
# AWS Cloudformation interaction either through the command line, or programatically
# from another class or gem.
module Launcher

  # Determine the path to where this gem currently resides on the host filesystem
  #
  # @return [String] the filepath to where this gem is located.
  def self.root
    Gem::Specification.find_by_name("envdude").gem_dir
  end

  # Initializes and returns a new Cloudformation client, using the configured
  # or discovered credential information from the client.
  #
  # @note Multiple calls to this method will return the same instantiated
  #   object.
  #
  # @return [Aws::Cloudformation::Client] an initialized client
  def self.cloudformation_client
    @client ||= Aws::CloudFormation::Client.new Launcher::Config::AWS.configuration
  end

  # For testing purposes, stubs the cloudformation client so that no HTTP requests
  # are made and stubbed responses can be generated.
  #
  # @note This method should never be used outside of a testing environment, as it
  #   will cause all other aws-related actions to have no effect.
  #
  # @return void
  def self.stub!
    @client = Aws::CloudFormation::Client.new stub_responses: true
  end

  # Provides classes with the ability to store messages for consumption
  # elsewhere within the application. Typically via the CLI.
  #
  # @example Including and using the {Launcher::Message} module.
  #   class Foo
  #     include Launcher::Message
  #     def initialize
  #       message "The class has been initialized!", :type => :ok
  #     end
  #   end
  module Message

    attr :messages

    attr_reader :message_proc

    # Binds a message handler to proc a block when a message
    # is added to the messages array.
    #
    # @param [Proc] message_proc the block to call when a message is added.
    def message_handler(&message_proc)
      @message_proc = message_proc
    end

    # Places a new message into the messages array and optionally
    # calls a block passed into the action handler.
    #
    # @param [String] msg to add to the messages array.
    def message(msg, options={})
      (@messages ||= []) << options.merge({:message => msg})
      proc_with_message(messages.last, &@message_proc) if @message_proc
    end

    # Retrieve the underlying messages array or pass them
    # through a block.
    def messages(&block)
      @messages.each { |m| proc_with_message(m, &block) } if block
      return @messages
    end

    private

    def proc_with_message(msg, &block)
      block.call(msg[:message], msg)
    end

  end

end
