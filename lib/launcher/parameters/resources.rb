require 'aws-sdk'

module Launcher
  class Parameters
    # This class, upon initialization interrogates the resources created 
    # by a Cloudformation for their logical resource ID. If a resource does
    # no have one, it is not included.
    class Resources < Hash

      def initialize
        if aws_configured?
          stacks.each do |stack|
            stack.resources.each do |resource|
              self[resource.logical_resource_id] = resource.physical_resource_id
            end
          end
        end
      end

      private

        def stacks
          cloudformation.stacks
        end

        def cloudformation
          AWS::CloudFormation.new
        end

        def aws_configured?
          Launcher::Config::AWS.configured?
        end

    end
  end
end