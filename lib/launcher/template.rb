require 'json'

module Launcher
  # Loads a pre-existing AWS Cloudformation template, that has a valid JSON structure.
  # This class is able to retrieve different parts of the Cloudformation, as well as
  # modify its contents and return them in a JSON encoded string.
  #
  # @example Loading an AWS Cloudformation Template
  #   my_template = Launcher::Template.new("path/to/my/template.json")
  #
  # @example Loading and retrieving a Cloudformation parameter hash
  #   my_template = Launcher::Template.new("path/to/my/template.json")
  #   my_parameters = my_template.parameters
  class Template

    include Launcher::Message

    attr_reader :json, :file_path

    def initialize(file_path)
      @file_path = file_path
      @json = JSON.parse(read, symbolize_names: true)
    end

    # Retrieve the name of the template. The name is derived such that
    # any characters preceeding the first . character (by default) form the name.
    #
    # @example Retrieving the name of a template
    #   my_template = Launcher::Template.new("path/to/my/vpc-network.template.json")
    #   my_template.name # => "vpc-network"
    def name(splitter=".")
      filename.split(splitter)[0]
    end

    # Retrieve the full filename for the template that has been loaded.
    #
    # @return [String] the full filename.
    def filename
      Pathname.new(file_path).basename.to_s
    end

    # Return the file handler for the template filepath that the class has been
    # initialized with.
    #
    # @return [File] open file handle with read-in-binary permissions.
    def file
      File.open(file_path, "rb")
    end

    # Return the template files contents as a string.
    #
    # @return [String] The templates file contents with newline characters.
    def read
      @contents ||= if (read = File.read(file_path)).empty?
        '{}'
      else
        read
      end
    end

    # Return the loaded templates Cloudformation Parameters as a Hash.
    # @return [Hash] the defined parameters from inside the Cloudformation, along with their property set.
    def parameters
      @json[:Parameters].dup
    end

    # Return the loaded templates Cloudformation Mapping as a Hash.
    # @return [Hash] the defined mappings from inside the Cloudformation, along with their property set.
    def mappings
      @json[:Mappings].dup
    end

    # Return the loaded templates Cloudformation Resources as a Hash.
    # @return [Hash] the defined resources from inside the Cloudformation, along with their property set.
    def resources
      @json[:Resources].dup
    end

    # Return the loaded templates Cloudformation Outputs as a Hash.
    # @return [Hash] the defined ouputs from inside the Cloudformation, along with their property set.
    def outputs
      @json[:Outputs].dup
    end

    # Determines if the Cloudformation is valid. This function attempts to identify additional validity
    # errors that the validate_template function may not pick up on, such that there must be at least one
    # resource defined.
    #
    # @note Validation error messages are sent via the {Launcher::Message} module.
    #
    # @return [Boolean] True if the template is valid, false otherwise.
    def valid?
      valid = true
      if resources.keys.empty?
        message "Atleast once templated resource must be defined.", :type => :fatal
        valid = false
      end
      valid
    end

    # Returns a subset of the Cloudformation parameters that contain defaulted values.
    #
    # @return [Hash] A hash of the defaulted parameters for the loaded Cloudformation.
    def defaulted_parameters
      parameters.keep_if { |k,v| v.has_key?(:Default) }
    end

    # Returns a subset of the Cloudformation parameters that do not contain default values.
    # These parameters indicate that they need to be passed in to the cloudformation upon
    # creation or update.
    #
    # @return [Hash] A hash of the non-defaulted parameters for the loaded Cloudformation.
    def non_defaulted_parameters
      parameters.reject { |k| defaulted_parameters.keys.include?(k) }
    end

  end
end
