require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'coveralls'
Coveralls.wear!

require 'aws-sdk'
require 'factory_girl'
require 'launcher'

Launcher.stub!

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

end
