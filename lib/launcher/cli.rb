require 'thor'
require 'launcher'
require 'terminal-table'

require 'launcher/cli/stack'
require 'launcher/cli/template'

require 'launcher/log'
require 'launcher/parameters'
require 'launcher/stacks'

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

    class_option :access_key_id, type: :string
    class_option :secret_access_key, type: :string
    class_option :region, type: :string, default: 'us-east-1'
    class_option :profile, type: :string

    def initialize(*args)
      super
      Launcher::Config(options)
      describe_aws_configuration
    end

    desc "version", "Displays the current version number of Launcher."
    # Displays the current version of the installed Launcher gem on the command line.
    # For more help on this command, use `launcher help version` from the command line.
    def version
      Launcher::Log.info Launcher::VERSION
    end

    desc "list", "List all automatically discoverable AWS Cloudformation Parameters"
    method_option :filter, :type => :string, :desc => "Filter parameter keys returned using a regular expression (use single quotes)."
    # Displays a table within the command line of all the parameters that have been discovered, or those that have
    # passed through a provided regular expression filter.
    # For more help on this command, use `launcher help list` from the command line.
    def list
      discovered = Launcher::Parameters.new
      Launcher::Log.ok "Discovered #{discovered.count} parameters."
      rows = []
      discovered.each { |key, value|
        val = value[0..30] + (value.length > 30 ? "..." : "")
        rows << [key, val]
      }
      Launcher::Log.ok "\n", Terminal::Table.new(:headings => ["Key", "Value"], :rows => rows)
    end

    desc "stacks", "Lists the status and other information for all AWS Cloudformation Stacks."
    # Displays a table within the command line describing the current status and other information
    # for every Cloudformation that is currently launched.
    # For more help on this command, use `launcher help list` from the command line.
    def stacks
      rows = []
      Launcher::Stacks.new.all_statuses { |s| rows << [s[:name], s[:updated_at], s[:status]] }
      Launcher::Log.ok "\n", Terminal::Table.new(:headings => ["Name", "Updated At", "Status"], :rows => rows)
    end

    desc "stack COMMAND ...ARGS", "Perform stack based commands."
    # The stack subcommand class, accessed via the command line using `launcher stack ...`
    subcommand "stack", Launcher::CLI::Stack

    desc "template COMMAND ...ARGS", "Perform cloudformation template based commands."
    # The stack subcommand class, accessed via the command line using `launcher stack ...`
    subcommand "template", Launcher::CLI::Template

    private

    def aws_configuration
      Launcher::Config::AWS.configuration
    end

    def aws_configured?
      aws_configuration[:credentials] != nil
    end

    def describe_aws_configuration
      if aws_configured?
        config = aws_configuration
        Launcher::Log.info "AWS Region #{config[:region]}"
        Launcher::Log.info "AWS Access Key #{config[:access_key_id]}"
      else
        Launcher::Log.warn "No AWS config detected."
      end
    end

  end
end
