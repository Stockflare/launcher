module Launcher
  module Config
    module AWS
      # This module attempts to discover AWS Configuration from any configuration
      # file present inside the users home directory. On Linux, this is `~/.aws/config`
      # and the corresponding directory on Windows.
      module ConfigFile

        # Determines if a configuration file is present and readble at the
        # defined location.
        #
        # @return [Boolean] True if AWS configuration file present, false otherwise.
        def self.present?
          readable? && exists?
        end

        protected

          def self.readable?
            File.readable?(path)
          end

          def self.exists?
            File.exist?(path)
          end

          def self.configuration
            if present?
              configuration = {}
              File.readlines(path).each do |line|
                key, value = line.split('=')
                if (key && value)
                  key.gsub!(/aws_/, '')
                  configuration[:"#{key}"] = value.gsub!(/^[ ]+|[ ]+$|\n/,'')
                end
              end
              return configuration
            end
          end

        private

          @@default_config_path = "~/.aws/config"

          def self.path
            File.expand_path(@@default_config_path)
          end

      end
    end
  end
end