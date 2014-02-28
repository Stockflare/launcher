require 'spec_helper'

require 'launcher/parameters'
require 'launcher/stack'

describe Launcher::Stack do

  include FakeFS::SpecHelpers

  let(:file_path) { "file.cloudformation" }
  let(:template) { build(:template) }
  #let(:test_params) { { :foo => "bar", :x => "y" } }
  let(:name) { "test" }

  before { 
    Launcher::Config::AWS.stub(:configured?) { false }
    Launcher::Config(:params => template[:Parameters])

    File.open(file_path, "wb") do |f|
      f.write template.to_json
    end

    @template = Launcher::Template.new(file_path)
    @parameters = Launcher::Parameters.new
    @stack = Launcher::Stack.new(name, @template, @parameters)
  }

  after { Launcher::Config.delete!(:params) }

  subject { @stack }

  it { should be_kind_of(Launcher::Message) }
  it_behaves_like "a class that stores messages"

  it { should respond_to(:create) }
  it { should respond_to(:update) }
  it { should respond_to(:cost) }
  it { should respond_to(:parameters) }
  it { should respond_to(:filtered_parameters) }
  it { should respond_to(:missing_parameters) }
  it { should respond_to(:missing_parameters?) }
  it { should respond_to(:valid?) }

  it { should be_valid }

  describe "as a cloudformation is created" do

    it "should create a cloudformation" do
      expect { @stack.create }.to_not raise_error
    end

    it "should send a message" do
      expect { |b|
        @stack.message_handler &b
        @stack.create
      }.to yield_control.at_least(1)
    end
  end

  describe "as a cloudformation is updated" do

    describe "when the cloudformation exists" do

      before {
        AWS::CloudFormation.stub(:stacks) {
          {
            "#{name}" => class CloudformationStack 
              def update(*); end
            end.new
          }
        }
      }

      it "should update an existing cloudformation" do
        expect { @stack.update }.to_not raise_error
      end

      it "should send a message" do
        expect { |b|
          @stack.message_handler &b
          @stack.update
        }.to yield_control.at_least(1)
      end
    end

    describe "when a cloudformation does not exist" do
      it "should raise an error" do
        @stack.should_receive(:message).at_least(:once) do |msg, opts|
          expect(opts[:type]).to eq(:fatal) if opts && opts.include?(:type)
        end
        @stack.update
      end
    end
    
  end

  describe "as a cloudformation is deleted" do

    describe "when the cloudformation exists" do

      before {
        AWS::CloudFormation.stub(:stacks) {
          {
            "#{name}" => class CloudformationStack 
              def update(*); end
            end.new
          }
        }
      }

      it "should delete an existing cloudformation" do
        expect { @stack.delete }.to_not raise_error
      end

      it "should send a message" do
        expect { |b|
          @stack.message_handler &b
          @stack.delete
        }.to yield_control.at_least(1)
      end
    end

    describe "when a cloudformation does not exist" do
      it "should raise an error" do
        @stack.should_receive(:message).at_least(:once) do |msg, opts|
          expect(opts[:type]).to eq(:fatal) if opts && opts.include?(:type)
        end
        @stack.delete
      end
    end
    
  end

  describe "when parameters are missing" do
    before { @stack.stub(:missing_parameters?) { true } }
    it { should_not be_valid }
  end

  describe "return value of #parameters" do
    it "should be a hash" do
      expect(@stack.parameters).to be_a(Hash)
    end

    it "should include parameters and capabilities" do
      expect(@stack.parameters).to include(:parameters, :capabilities)
    end

    describe "when the capabilities include IAM" do
      it "should include the capability to create IAM Profiles" do
        expect(@stack.parameters[:capabilities]).to include("CAPABILITY_IAM")
      end
    end

    describe "when the parameters are filtered" do
      it "should include filtered parameters to be sent to the cloudformation" do
        expect(@stack.parameters[:parameters]).to eq @stack.filtered_parameters
      end
    end
  end

  describe "return value of #cost" do

    describe "when AWS is configured" do

      let(:test_url) { "http://test-url.com" }

      before {
        Launcher::Config::AWS.stub(:configured?) { true }
        Launcher::Stack.any_instance.stub(:valid?) { true }
        AWS::CloudFormation.any_instance.stub(:estimate_template_cost) { test_url }
      }

      it "should send a message" do
        @stack.should_receive(:message).at_least(:once) do |msg, opts|
          expect(opts[:type]).to eq(:ok) if opts && opts.include?(:ok)
        end
        @stack.cost
      end

      it "should send a message containing the url" do
        @stack.should_receive(:message).at_least(:once) do |msg, opts|
          expect(msg).to eq(test_url)
        end
        @stack.cost
      end

      it "should return a string" do
        expect(@stack.cost).to be_a(String)
      end

      it "should return a url" do
        expect(@stack.cost).to eq(test_url)
      end

    end

    describe "when AWS is not configured" do

      it "should return nil" do
        expect(@stack.cost).to be_nil
      end

    end
  end

  describe "return value of #missing_parameters" do
    it "should be an array" do
      expect(@stack.missing_parameters).to be_a(Array)
    end

    describe "when no parameters are missing" do
      it "should be empty" do
        expect(@stack.missing_parameters).to be_empty
      end

      describe "return value of #missing_parameters?" do
        it "should be false" do
          expect(@stack.missing_parameters?).to be_false
        end
      end
    end

    describe "when a parameter is missing" do
      let(:deleted_parameter) { @stack.filtered_parameters.keys.first }
      before { @stack.discovered_parameters.reject! { |k| k == deleted_parameter } }

      it "should not be empty" do
        expect(@stack.missing_parameters).to_not be_empty
      end

      it "should contain the missing parameter" do
        expect(@stack.missing_parameters).to include(deleted_parameter)
      end

      describe "return value of #missing_parameters?" do
        it "should be true" do
          expect(@stack.missing_parameters?).to be_true
        end
      end
    end
  end

  describe "return value of #filtered_parameters" do
    it "should be a hash" do
      expect(@stack.parameters).to be_a(Hash)
    end

    describe "when a parameter does not have a default" do
      let(:non_default_parameter_keys) { @template.non_defaulted_parameters.keys }

      it "should match the templates non default parameters" do
        expect(@stack.filtered_parameters.keys).to eq non_default_parameter_keys
      end
    end
  end
  
end