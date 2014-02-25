require 'aws-sdk'

module Launcher
  class Parameters
    # This class upon initialization will use defined AWS Access credentials
    # to discover all existing Cloudformation Ouput keys and values for the default
    # or defined AWS Region.
    class Configs < Hash

      include Launcher::Message

      def initialize
        files = configuration_files
        if files
          files.each do |file|
            if File.exist?(file)
              load_and_set(file)
            else
              message "File #{file} does not exist.", :type => :warn
            end
          end
        end
      end

      def configuration_files
        Launcher::Config[:config_files]
      end

      private

        def load_and_set(filepath)
          YAML::load_file(filepath)[:parameters].each do |key, value|
            if value.is_a?(String)
              self[key.to_sym] = value
            else
              message "Value for #{key} is not a string.", :type => :warn
            end
          end
        end

    end
  end
end