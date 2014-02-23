require "launcher/version"
require "launcher/config"

module Launcher

  def self.root
    Gem::Specification.find_by_name("envdude").gem_dir
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
    # @params [Proc] message_proc the block to call when a message is added. 
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
