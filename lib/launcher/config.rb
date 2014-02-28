require 'launcher/config/aws'

module Launcher

  # Adds configuration values to the current static instance of Launcher.
  #
  # @overload self.Config(config={})
  # @param [Hash] config of keys and values to add.
  def self.Config(config={})
    config.each do |key, value|
      Launcher::Config[key] = value
    end
  end

  # Controls all configuration settings for the Launcher gem.
  # @note This module should be accessed from within a static context.
  module Config

    # Retrieves values for the provided keys.
    # @note Keys not present within the configuration will be omitted from the returned hash.
    #
    # @example Guided Usage
    #   Launcher::Config.select(:a, :b, :c, :d)
    #
    # @param [Splat] args of the key value pairs to retrieve.
    # @return [Hash] a hash of the keys present within configuration. 
    def self.select(*args)
      @@_.select { |key| args.include?(key) }
    end

    # Accesses {Launcher::Config} as an array of key-based values.
    # 
    # @example Retrieve a singular key using a symbol
    #   Launcher::Config[:a]
    # @example Retrieve a singular key using a string
    #   Launcher::Config["a"]
    #
    # @param [Symbol] key of the value to retrieve.
    # @return [Mixed, Nil] Will return the value of the key or nil.
    def self.[](key)
      @@_[key.to_sym]
    end

    # Sets or modifies a key and value within the current configuration state.
    #
    # @example Usage
    #   Launcher::Config[:a] = "hello world!"
    #
    # @param [Symbol] key of the value to set.
    # @param [Mixed] value of the element.
    # @return [Mixed] the new value of the element.
    def self.[]=(key,value)
      @@_[key.to_sym] = value
    end

    # Removes a key from the current configuration state.
    #
    # @example Usage
    #   Launcher::Config.delete!(:one, :or, :more, :keys)
    #
    # @param [Symbol] keys of the values to delete.
    # @return [Hash] the values that have been deleted
    def self.delete!(*keys)
      keys.each { |k| @@_.delete(k.to_sym) }
    end

    private
      @@_ = {}

  end
end