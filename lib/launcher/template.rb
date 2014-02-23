require 'json'

module Launcher
  class Template

    include Launcher::Message

    attr_reader :json, :file_path

    def initialize(file_path)
      @file_path = file_path
      @json = JSON.parse(read, :symbolize_names => true)
    end

    def name(splitter=".")
      filename.split(splitter)[0]
    end

    def filename
      Pathname.new(@file_path).basename.to_s
    end

    def file
      File.open(@file_path, "rb")
    end

    def read
      File.read(@file_path)
    end

    def parameters
      @json[:Parameters].dup
    end

    def mappings
      @json[:Mappings].dup
    end

    def resources
      @json[:Resources].dup
    end

    def outputs
      @json[:Outputs].dup
    end

    def valid?
      valid = true

      if resources.keys.empty?
        message "Atleast once templated resource must be defined.", :type => :fatal
        valid = false
      end

      return valid
    end

    def defaulted_parameters
      parameters.keep_if { |k,v| v.has_key?(:Default) }
    end

    def non_defaulted_parameters
      parameters.reject { |k| defaulted_parameters.keys.include?(k) }
    end

  end
end