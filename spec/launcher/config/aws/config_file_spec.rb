require 'spec_helper'

require "launcher/config"
require "launcher/config/aws"

describe Launcher::Config::AWS::ConfigFile do

  include FakeFS::SpecHelpers

  let(:file_path) { "config" }
  
  before {
    Launcher::Config::AWS::ConfigFile.stub(:path) { file_path }
  }

  subject { Launcher::Config::AWS::ConfigFile }

  describe "when a config file exists" do

    before do
      File.open(file_path, "wb") do |f|
        f.puts "[default]"
        f.puts "aws_access_key_id=foo"
        f.puts "aws_secret_access_key=bar"
      end
    end

    it "should be present" do
      expect(subject.present?).to be_true
    end

    describe "return value of configuration" do

      it "should be a hash" do
        expect(subject.configuration).to be_a(Hash)
      end

      it "should contain configuration keys" do
        expect(subject.configuration.keys).to eq([:access_key_id, :secret_access_key])
      end

      it "should return valid aws configuration" do
        expected_configuration = { :access_key_id => "foo", :secret_access_key => "bar" }
        expect(subject.configuration).to eq(expected_configuration)
      end

    end

  end

  describe "when a config file does not exist" do

    it "should not be present" do
      expect(subject.present?).to_not be_true
    end

  end

end