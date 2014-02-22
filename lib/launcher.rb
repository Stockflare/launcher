require "launcher/version"
require "launcher/config"

module Launcher
  def self.root
    Gem::Specification.find_by_name("envdude").gem_dir
  end
end
