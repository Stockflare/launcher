module Launcher
  module Config
    module AWS
      # This module will discover AWS Configuration variables that
      # are present inside the current execution environment (ENV).
      #
      # @example Setting an AWS Configuration value in the environment on Unix.
      #   export AWS_ACCESS_KEY="my_access_key"
      module Environment

        # Determines if AWS Configuration values are present within the
        # environment (ENV).
        #
        # @return [Boolean] true if they are present, false otherwise.
        def self.present?
          (ENV.keys & @@mappings.values).length == @@mappings.length
        end

        protected

          def self.configuration
            if present?
              configuration = {}
              @@mappings.each do |key, value|
                configuration[key] = ENV[value]
              end
              @@optional_mappings.each do |key, value|
                configuration[key] = ENV[value] if ENV[value]
              end
              return configuration
            end
          end
        
        private

          @@mappings = {
            :access_key_id => 'AWS_ACCESS_KEY',
            :secret_access_key => 'AWS_SECRET_KEY'
          }

          @@optional_mappings = {
            :region => 'AWS_REGION'
          }

      end
    end
  end
end