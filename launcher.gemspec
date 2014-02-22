# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'launcher/version'

Gem::Specification.new do |spec|
  spec.name          = "launcher"
  spec.version       = Launcher::VERSION
  spec.authors       = ["davidkelley"]
  spec.email         = ["david.james.kelley@gmail.com"]
  spec.description   = %q{Launches AWS Cloudformation templates that can use pre-existing Stack outputs as parameters.}
  spec.summary       = %q{Launches AWS Cloudformation templates.}
  spec.homepage      = "http://github.com/davidkelley/launcher"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "aws-sdk"
  spec.add_dependency "colored"
  spec.add_dependency "terminal-table"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "redcarpet"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "fakefs"
end
