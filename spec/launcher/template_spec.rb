require 'spec_helper'

require 'launcher/template'

describe Launcher::Template do

  include FakeFS::SpecHelpers

  let(:file_path) { "file.cloudformation" }

  let(:template) { build(:template) }

  before do
    File.open(file_path, "wb") do |f|
      f.write template.to_json
    end
    @template = Launcher::Template.new(file_path)
  end

  subject { @template }

  it { should respond_to(:file) }
  it { should respond_to(:json) }
  it { should respond_to(:file_path) }
  it { should respond_to(:filename) }
  it { should respond_to(:name) }
  it { should respond_to(:parameters) }
  it { should respond_to(:mappings) }
  it { should respond_to(:resources) }
  it { should respond_to(:outputs) }
  it { should respond_to(:defaulted_parameters) }
  it { should respond_to(:non_defaulted_parameters) }

  it { should be_valid }

  it "should retrieve the correct filename" do
    expect(@template.filename).to eq file_path
  end

  it "should retrieve the correct template name" do
    expect(@template.name).to eq file_path.split(".")[0]
  end

  describe "when there are no resources defined" do
    before { @template.stub(:resources) { {} } }
    it { should_not be_valid }
  end

  describe "when a new template is initialized" do

    it "should recall the #file_path" do
      expect(@template.file_path).to eq file_path
    end

    it "should read the file contents" do
      expect(@template.read).to eq template.to_json
    end

    describe "and I request the json" do
      it "should return a hash" do
        expect(@template.json).to be_a(Hash)
      end

      it "should parse the contents of the file" do
        expect(@template.json).to eq(template)
      end
    end

  end

  describe "return value of #defaulted_parameters" do
    it "should be a hash" do
      expect(@template.defaulted_parameters).to be_a(Hash)
    end

    it "should be the correct parameters" do
      expected = @template.parameters.keep_if { |k,v| v.has_key?(:Default) }
      expect(@template.defaulted_parameters).to eq expected
    end
  end

  describe "return value of #non_defaulted_parameters" do
    it "should be a hash" do
      expect(@template.non_defaulted_parameters).to be_a(Hash)
    end

    it "should be the correct parameters" do
      expected = @template.parameters.reject { |k,v| v.has_key?(:Default) }
      expect(@template.non_defaulted_parameters).to eq expected
    end
  end

  describe "return value of #parameters" do
    it "should be a hash" do
      expect(@template.parameters).to be_a(Hash)
    end

    it "should be the correct contents" do
      expect(@template.parameters).to eq(template[:Parameters])
    end
  end

  describe "return value of #mappings" do
    it "should be a hash" do
      expect(@template.mappings).to be_a(Hash)
    end

    it "should be the correct contents" do
      expect(@template.mappings).to eq(template[:Mappings])
    end
  end

  describe "return value of #resources" do
    it "should be a hash" do
      expect(@template.resources).to be_a(Hash)
    end

    it "should be the correct contents" do
      expect(@template.resources).to eq(template[:Resources])
    end
  end

  describe "return value of #outputs" do
    it "should be a hash" do
      expect(@template.outputs).to be_a(Hash)
    end

    it "should be the correct contents" do
      expect(@template.outputs).to eq(template[:Outputs])
    end
  end
  
end