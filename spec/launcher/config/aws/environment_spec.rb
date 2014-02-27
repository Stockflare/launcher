require 'spec_helper'

require "launcher/config"
require "launcher/config/aws"

describe Launcher::Config::AWS::Environment do

  subject { Launcher::Config::AWS::Environment }

  describe "when credential environment variables exist" do

    before do
      ENV['AWS_ACCESS_KEY'] = "foo"
      ENV['AWS_SECRET_KEY'] = "bar"
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

      describe "when a region is set" do
        before { ENV['AWS_REGION'] = "eu" }

        it "should contain configuration keys" do
          expect(subject.configuration.keys).to eq([:access_key_id, :secret_access_key, :region])
        end

        it "should return valid aws configuration" do
          expected_configuration = { :access_key_id => "foo", :secret_access_key => "bar", :region => "eu" }
          expect(subject.configuration).to eq(expected_configuration)
        end
      end

    end

  end

  describe "when environment variables do not exist" do

    before do
      ENV.delete('AWS_ACCESS_KEY')
      ENV.delete('AWS_SECRET_KEY')
      ENV.delete('AWS_REGION')
    end

    it "should not be present" do
      expect(subject.present?).to_not be_true
    end

  end

end