require 'pp'
require 'fakefs/spec_helpers'
require 'factory_girl'
require 'launcher'

FactoryGirl.find_definitions
 
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end