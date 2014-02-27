require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'coveralls'
Coveralls.wear!



require 'pp'
require 'aws-sdk'
require 'fakefs/spec_helpers'
require 'factory_girl'
require 'launcher'

AWS.stub!

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

FactoryGirl.find_definitions
 
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end