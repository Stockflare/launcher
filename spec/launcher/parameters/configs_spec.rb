require 'spec_helper'

require 'launcher/parameters/configs'

describe Launcher::Parameters::Configs do

  include FakeFS::SpecHelpers

  let(:file_path) { "example.configuration.yml" }

  let(:config_contents) {
    {
      :parameters => {
        :foo => "bar",
        :bar => "foo"
      }
    }
  }

  before do
    File.open(file_path, "wb") do |f|
      f.write config_contents.to_yaml
    end
    
    Launcher::Config(:config_files => [file_path])
    @configs = Launcher::Parameters::Configs.new 
  end

  subject { @configs }

  it { should be_kind_of(Launcher::Message) }
  it_behaves_like "a class that stores messages"

  it { should respond_to(:configuration_files) }

  describe "return value of the class" do
    it "should be a hash" do
      expect(@configs).to be_a(Hash)
    end

    it "should contain configuration contents" do
      expect(@configs).to eq config_contents[:parameters]
    end
  end

  describe "when two configuration files are defined" do
    describe "when there are duplicate keys" do

      before { Launcher::Config(:config_files => [file_path, file_path]) }

      it "should not duplicate keys" do
        expect(@configs.keys.count).to eq config_contents[:parameters].keys.count
      end
    end

    describe "when there are different keys present" do

      let(:second_file_path) { "second.configuration.yml" }

      let(:second_config_contents) {
        {
          :parameters => {
            :foo => "bar",
            :bar => "foo",
            :test => "aaaa"
          }
        }
      }

      before do
        File.open(second_file_path, "wb") do |f|
          f.write second_config_contents.to_yaml
        end
        
        Launcher::Config(:config_files => [file_path, second_file_path])
        @configs = Launcher::Parameters::Configs.new 
      end

      it "should merge keys in different files" do
        expected_config = config_contents[:parameters].keys && second_config_contents[:parameters].keys
        expect(@configs.keys).to eq(expected_config)
      end

    end
  end
  
end