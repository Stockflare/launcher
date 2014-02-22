require 'launcher/parameters/outputs'

module Launcher
  # Discovers all parameters from passed parameters, configuration files and from 
  # pre-existing Cloudformation Stack outputs.
  class Parameters

    attr_reader :outputs, :params, :configuration

    def initialize(params={})
      @params = params
      @configuration = {}
      @outputs = Launcher::Parameters::Outputs.new
    end

    def all
      {}.merge(@outputs).merge(@params).merge(@configuration)
    end

    def [](key)
      all[key]
    end

    def select(*args)
      all.select { |key| args.include?(key) }
    end

  end
end