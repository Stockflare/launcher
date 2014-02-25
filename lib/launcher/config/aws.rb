require "launcher/config/aws/environment"
require "launcher/config/aws/config_file"

module Launcher
  module Config
    # Handles AWS Configuration for the Launcher gem. This module can be included
    # within a class to enable AWS configuration variables, or accessed externally.
    # AWS Configuration is retrieved from a configuration file, or from the environment.
    #
    # See the AWS configuration setup for more information.
    module AWS
      # Retrieves a specific AWS Configuration key. Note that
      # the values retrieved are filtered based upon valid AWS
      # configuration keys.
      #
      # @example Retrieving a value
      #   Launcher::Config::AWS[:access_key_id]
      #
      # @param [Symbol] key to use to retrieve a value.
      # @return [String,Nil] the value stored under the key.
      def self.[](key)
        configuration[key] if @@keys.include?(key)
      end

      # Determines if AWS configuration values are set within the current
      # state of {Launcher::Config}.
      #
      # @return [Boolean] True if AWS configuration is present, false otherwise.
      def self.configured?
        configuration.length >= 2
      end

      # Retreives and attempts to discover all set AWS configuration 
      # values from the current {Launcher::Config} state. This function
      # will return configurable values that have been set in command parameters,
      # the environment and finally any configuration file, respectively.
      #
      # @return [Hash,Nil] the current AWS Configuration values
      def self.configuration
        config = aws_configuration
        if config.length < 2
          if self::Environment.present?
            Launcher::Config(self::Environment.configuration)
          elsif self::ConfigFile.present?
            Launcher::Config(self::ConfigFile.configuration)
          end
        end
        ::AWS.config(config)
        config
      end

      private

        @@keys = [:access_key_id, :secret_access_key, :region]

        def self.aws_configuration
          Launcher::Config.select(*@@keys)
        end
      
    end
  end
end