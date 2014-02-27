require 'spec_helper'

require "launcher/config"
require "launcher/config/aws"

describe Launcher::Config::AWS do

  let(:test_data) { { :access_key_id => "aki", :secret_access_key => "sak" } }

  it "should be present" do
    expect(subject).to_not be_nil
  end

  describe "when configuration is set" do
    before {
      Launcher::Config(test_data)
    }

    it "should set configuration" do
      expect(subject.configuration).to eq test_data
    end

    it "should filter configuration" do
      Launcher::Config(test_data.merge(:another_key => true))
      expect(subject.configuration).to eq test_data
    end

    it "should return a specific key" do
      expect(subject[test_data.keys.first]).to eq test_data.values.first
    end

    it "should be configured?" do
      expect(subject.configured?).to be_true
    end
  end

  describe "when configuration is not set" do

    before { Launcher::Config.delete!(:access_key_id, :secret_access_key) }

    it "should not be configured?" do
      expect(subject.configured?).to_not be_true
    end

    it "should not return configuration" do
      expect(subject.configuration).to eq({})
    end
  end

end