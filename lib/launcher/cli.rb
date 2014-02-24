require 'thor'
require 'launcher'
require 'terminal-table'

require 'launcher/cli/stack'

require 'launcher/log'
require 'launcher/parameters'

# require all configurables
Dir[File.dirname(__FILE__) + "/cli/**/*.rb"].each {|file| require file }

module Launcher
  # Provides a Command Line Interface for the Launcher gem. See the method definitions
  # for more information on its usage.
  #
  # @example Checking the version
  #   launcher version
  class CLI < Thor

    package_name "Launcher"

    class_option :access_key_id, :type => :string
    class_option :secret_access_key, :type => :string
    class_option :region, :type => :string, :default => "eu-west-1"

    def initialize(*args)
      super
      Launcher::Config(options)
      describe_aws_configuration
    end

    desc "version", "Displays the current version number of Launcher."
    # Displays the current version of the installed Launcher gem on the command line.
    def version
      Launcher::Log.info Launcher::VERSION
    end    

    desc "list", "List all automatically discoverable AWS Cloudformation Parameters"
    def list
      discovered = Launcher::Parameters.new.all

      Launcher::Log.ok "Discovered #{discovered.count} parameters."
      rows = []
      discovered.each { |key, value| 
        val = value[0..30] + (value.length > 30 ? "..." : "")
        rows << [key, val] 
      }
      puts Terminal::Table.new :headings => ["Parameter", "Value"], :rows => rows
    end

    desc "configuration", "Lists the detected configuration that Launcher will use to connect with the AWS API."
    def configuration
    end

    desc "stack COMMAND ...ARGS", "Perform stack based commands."
    subcommand "stack", Launcher::CLI::Stack

    private

      def describe_aws_configuration
        configuration = Launcher::Config::AWS.configuration
        unless configuration.empty?
          Launcher::Log.info "Using Region #{configuration[:region]}"
          secret_access_key = configuration[:secret_access_key]
          masked_secret = secret_access_key.slice(0, secret_access_key.length/2)
          Launcher::Log.info "Using Access Key #{configuration[:access_key_id]} with secret #{masked_secret}..."
        else
          Launcher::Log.error "No AWS Configuration detected."
        end
      end

  end
end