module Launcher
  class Template

    attr_reader :file, :json, :file_path

    def initialize(file_path)
      @file_path = file_path
      @file = File.open(@file_path, "r")
      @json = JSON.parse(@file.read)
    end

    def raw_json
      @file.read
    end

  end
end