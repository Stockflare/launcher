require 'aws-sdk'

module Launcher
  class Launch

    def initialize(name, template, params)
      cloudformation.stacks.create(name, template.raw_json, :parameters => params)
    end

    private

      def cloudformation
        AWS::CloudFormation.new Launcher::Config::AWS.configuration
      end
  end
end