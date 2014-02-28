require "logger"
require "colored"

module Launcher
  # The Log class provides a static interface to output text to STDOUT.
  # It provides helpful messages types such as debug, error and ok. On
  # most command line interfaces, {Launcher::Log} will also output text
  # from various messages types in an appropriate color.
  #
  # @example Sending a log message
  #   Launcher::Log.fatal "My fatal error is", eexception.class.name
  class Log


    %w(debug error info warn fatal ok).each do |type|
      define_singleton_method(type) do |*msgs|
        @@log.send(type, *msgs.join(' '))
      end
    end

    # Print an OK log message using a concatenation of various strings
    # that have been passed in.
    #
    # @example Sending an OK Message
    #   Launcher::Log.ok "Hello", username # => "Hello David"
    def self.ok(*msgs)
      print color(format_msg("OK", *msgs.join(' ')), :ok)
    end

    protected

      def self.color(msg, type)
        self.send("color_#{type}", msg)
      end

      def self.format_msg(severity, msg, datetime=Time.now)
        "[#{datetime}] [#{severity}]: #{msg}\n"
      end

    private

      def self.color_ok(msg)
        msg.bold.green
      end

      def self.color_info(msg)
        msg.blue
      end

      def self.color_debug(msg)
        msg.underline.white
      end

      def self.color_error(msg)
        msg.red
      end

      def self.color_fatal(msg)
        msg.underline.red
      end

      def self.color_warn(msg)
        msg.yellow
      end

      @@log = Logger.new(STDOUT)

      @@log.formatter = proc { |severity, datetime, progname, msg|
        color format_msg(severity, msg, datetime), severity.downcase
      }

  end
end