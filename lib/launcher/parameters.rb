require 'launcher/parameters/outputs'
require 'launcher/parameters/options'
require 'launcher/parameters/resources'
require 'launcher/parameters/configs'

module Launcher
  # Discovers all parameters from passed parameters, configuration files and from
  # pre-existing Cloudformation Stack outputs.
  class Parameters < Hash

    def initialize
      AWS.memoize do
        [:options, :configs, :resources, :outputs].each do |c|
          self.merge!(Launcher::Parameters.const_get(c.to_s.capitalize).new)
        end
        self.reject! { |k| filtered?(k) }
      end
    end

    # Returns the current filter that has been used to filter out keys
    # from the parameters that are desired. Note then when setting a filter
    # it must be defined in {Launcher::Config}, as keys are filtered upon
    # initialization.
    #
    # @example Setting a Filter
    #   Launcher::Config(:filter => '\Afo+\Z')
    #   Launcher::Parameters.new.filter # => /\Afoo?\Z/
    #
    # @return [Regexp,Nil] Regular Expression if filter is set, Nil otherwise.
    def filter
      filter = Launcher::Config[:filter]
      Regexp.new(filter) unless filter.nil?
    end

    # Determines if a key is to be filtered out of the resultant Hash.
    # This method uses the #filter method and matches the key against
    # the regular expression.
    #
    # @return [Boolean] True if key is filtered out, false otherwise.
    def filtered?(key)
      unless filter.nil?
        (key.to_s =~ filter).nil?
      else
        false
      end
    end

  end
end
