require 'aws-sdk'

module Launcher
  class Parameters < Hash
    # This class upon initialization will use defined AWS Access credentials
    # to discover all existing Cloudformation Ouput keys and values for the default
    # or defined AWS Region.
    class Outputs < Hash

      def initialize
        if aws_configured?
          stacks.each do |stack|
            stack.outputs.each do |output|
              self[output.key.to_sym] = output.value
            end
          end
        end
      end

      # Retrieves an AWS::Cloudformation::StackCollection object containing
      # an enumerable list of pre-existing Cloudformation stacks that have been
      # detected using the credentials defined.
      #
      # @return [AWS::Cloudformation::StackCollection] collection of existing stacks.
      def stacks
        cloudformation.stacks
      end

      private

        def cloudformation
          AWS::CloudFormation.new
        end

        def aws_configured?
          Launcher::Config::AWS.configured?
        end

    end
  end
end