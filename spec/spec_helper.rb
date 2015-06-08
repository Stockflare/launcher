require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'coveralls'
Coveralls.wear!

require 'aws-sdk'
require 'factory_girl'
require 'launcher'

Dir["./spec/support/**/*.rb"].sort.each {|f| require f}

FactoryGirl.find_definitions

RSpec.configure do |config|

  config.include FactoryGirl::Syntax::Methods

  config.before :all, type: :request do
    puts "ERE"
    Launcher.stub(:cloudformation_client).with(Aws::Cloudformation::Client.new(stub_response: true))
  end

end
