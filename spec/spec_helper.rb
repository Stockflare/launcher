require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'pp'
require 'fakefs/spec_helpers'
require 'factory_girl'
require 'launcher'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

FactoryGirl.find_definitions
 
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end