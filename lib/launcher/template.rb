require 'json'

module Launcher
  class Template

    attr_reader :json, :file_path

    def initialize(file_path)
      @file_path = file_path
      @json = JSON.parse(read, :symbolize_names => true)
    end

    def file
      File.open(@file_path, "rb")
    end

    def read
      File.read(@file_path)
    end

    def parameters
      @json[:Parameters]
    end

    def mappings
      @json[:Mappings]
    end

    def resources
      @json[:Resources]
    end

    def outputs
      @json[:Outputs]
    end

    def defaulted_parameters
      parameters.keep_if { |k,v| v.has_key?(:Default) }
    end

    def non_defaulted_parameters
      parameters.reject { |k| defaulted_parameters.keys.include?(k) }
    end

  end
end