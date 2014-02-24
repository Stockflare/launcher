require 'launcher/parameters/outputs'
require 'launcher/parameters/resources'

module Launcher
  # Discovers all parameters from passed parameters, configuration files and from 
  # pre-existing Cloudformation Stack outputs.
  class Parameters

    attr_reader :outputs, :params, :configuration, :resources

    def initialize(params={})
      AWS.memoize do
        @params = params
        @configuration = {}
        @resources = Launcher::Parameters::Resources.new
        @outputs = Launcher::Parameters::Outputs.new
      end
    end

    def all
      {}.merge(@outputs).merge(@params).merge(@configuration).merge(@resources)
    end

    def [](key)
      all[key]
    end

    def select(*args)
      all.select { |key| args.include?(key) }
    end

  end
end