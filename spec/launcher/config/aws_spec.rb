require 'spec_helper'

require "launcher/config"
require "launcher/config/aws"

describe Launcher::Config::AWS do

  let(:test_data) { { :access_key_id => "aki", :secret_access_key => "sak" } }

  it "should be present" do
    expect(subject).to_not be_nil
  end

  it "should set configuration" do
    Launcher::Config(test_data)
    subject.configuration.should == test_data
  end

  it "should filter configuration" do
    Launcher::Config(test_data.merge(:another_key => true))
    subject.configuration.should == test_data
  end

  it "should return a specific key" do
    subject[test_data.keys.first].should == test_data.values.first
  end

end