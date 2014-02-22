require 'thor'
require 'launcher'

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

    class_option :access_key_id, :type => :string, :aliases => "-ak"
    class_option :secret_access_key, :type => :string, :aliases => "-ask"

    desc "version", "Displays the current version number of Launcher."
    # Displays the current version of the installed Launcher gem on the command line.
    def version
      puts Launcher::VERSION
    end

  end
end