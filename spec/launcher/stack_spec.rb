require 'spec_helper'

require 'launcher/parameters'
require 'launcher/stack'

describe Launcher::Stack do

  include FakeFS::SpecHelpers

  let(:file_path) { "file.cloudformation" }
  let(:template) { build(:template) }
  let(:parameters) { build(:parameters) }

  before { 
    Launcher::Config::AWS.stub(:configured?) { false }

    File.open(file_path, "wb") do |f|
      f.write template.to_json
    end

    @template = Launcher::Template.new(file_path)
    @stack = Launcher::Stack.new("test", @template, parameters.all)
  }

  subject { @stack }

  it { should be_kind_of(Launcher::Message) }
  it_behaves_like "a class that stores messages"

  it { should respond_to(:create) }
  it { should respond_to(:update) }
  it { should respond_to(:parameters) }
  it { should respond_to(:filtered_parameters) }
  it { should respond_to(:missing_parameters) }
  it { should respond_to(:missing_parameters?) }
  it { should respond_to(:valid?) }

  it { should be_valid }

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