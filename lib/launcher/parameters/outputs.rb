require 'aws-sdk'

module Launcher
  class Parameters < Hash
    # This class upon initialization will use defined AWS Access credentials
    # to discover all existing Cloudformation Ouput keys and values for the default
    # or defined AWS Region.
    class Outputs < Hash

      def initialize
        outputs { |key, val| self[key] = val }
      end

      # This method iterates over all the outputs of all the stacks within
      # the currently connected AWS Account & Region combination.
      #
      # @yield [key, value] Yields the key and value of a stack output
      #
      # @yieldparam [Symbol] key of the output
      # @yieldparam [String] value of the output
      #
      # @return nil
      def outputs(&block)
        stacks.each do |stack|
          stack[:outputs].each do |output|
            block.call output[:ouput_key].to_sym, output[:output_value]
          end
        end
      end

      # Retrieves an Array of stacks containing
      # an enumerable list of pre-existing Cloudformation stacks that have been
      # detected using the credentials defined.
      #
      # @return [Array] array of existing stacks.
      def stacks
        client.describe_stacks[:stacks]
      end

      private

      def client
        Launcher.cloudformation_client
      end

    end
  end
end
