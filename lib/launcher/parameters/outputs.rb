require 'aws-sdk'

module Launcher
  class Parameters
    # This class upon initialization will use defined AWS Access credentials
    # to discover all existing Cloudformation Ouput keys and values for the default
    # or defined AWS Region.
    class Outputs < Hash

      def initialize
        cloudformation.stacks.each do |stack|
          stack.outputs.each do |output|
            self[output.key] = output.value
          end
        end
      end

      private

        def cloudformation
          AWS::CloudFormation.new Launcher::Config::AWS.configuration
        end

    end
  end
end