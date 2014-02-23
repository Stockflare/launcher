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

    desc "version", "Displays the current version number of Launcher."
    # Displays the current version of the installed Launcher gem on the command line.
    def version
      puts Launcher::VERSION
    end    

    desc "list", "List all automatically discoverable AWS Cloudformation Parameters"
    def list
      Launcher::Config(options)
      discovered = Launcher::Parameters.new(options[:params] || {}).all

      Launcher::Log.ok "Discovered #{discovered.count} parameters."
      rows = []
      discovered.each { |key, value| rows << [key, value] }
      puts Terminal::Table.new :headings => ["Parameter", "Value"], :rows => rows
    end

    desc "launcher stack COMMAND ...ARGS", "Perform stack based commands."
    subcommand "stack", Launcher::CLI::Stack

  end
end