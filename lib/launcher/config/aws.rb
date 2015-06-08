module Launcher
  module Config
    # Handles AWS Configuration for the Launcher gem. This module can be included
    # within a class to enable AWS configuration variables, or accessed externally.
    # AWS Configuration is retrieved from a configuration file, or from the environment.
    #
    # See the AWS configuration setup for more information.
    module AWS

      # Valid AWS Configuration keys
      KEYS = %i{access_key_id secret_access_key region profile}

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
        Config[key] if KEYS.include? key
      end

      # Returns a configuration hash that is compatible with Aws Client classes.
      #
      # @see http://docs.aws.amazon.com/sdkforruby/api/Seahorse/Client/Base.html
      #
      # @return [Hash] the current AWS Configuration
      def self.configuration
        { region: region, credentials: credentials }
      end

      def self.credentials
        if profile?
          Aws::SharedCredentials.new(profile_name: self[:profile])
        elsif keys?
          Aws::Credentials.new(self[:access_key_id], self[:secret_access_key])
        else
          nil
        end
      end

      def self.region
        self[:region]
      end

      private

      def self.profile?
        self[:profile]
      end

      def self.keys?
        self[:access_key_id] && self[:secret_access_key]
      end

    end
  end
end
