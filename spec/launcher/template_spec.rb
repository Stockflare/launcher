require 'spec_helper'

require 'launcher/template'

describe Launcher::Template do

  let(:file_path) { "file.cloudformation" }

  let(:template) { build(:template) }

  before do
    File.open(file_path, "wb") { |f| f.write template.to_json }
    @template = Launcher::Template.new(file_path)
  end

  subject { @template }

  it { should be_kind_of(Launcher::Message) }
  it_behaves_like "a class that stores messages"

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

  it "should retrieve the correct filename" do
    expect(@template.filename).to eq file_path
  end

  it "should retrieve the correct template name" do
    expect(@template.name).to eq file_path.split(".")[0]
  end

  describe "the return of valid?" do

    describe "when the template is valid" do
      describe "when AWS is configured" do
        before {
          Launcher::Config::AWS.stub(:configured?) { true }
          AWS::CloudFormation.any_instance.stub(:validate_template) { {} }
        }

        it "should not send any message" do
          expect { |b|
            @template.message_handler &b
            @template.valid?
          }.to_not yield_control
        end

        it { should be_valid }

      end
    end

    describe "when the template is not valid" do

      describe "when there are no resources defined" do
        before { @template.stub(:resources) { {} } }
        it { should_not be_valid }
      end

      describe "when AWS is not configured" do
        before { Launcher::Config::AWS.stub(:configured?) { false } }

        it "should send a warning message" do
          @template.should_receive(:message).at_least(:once) do |msg, opts|
            expect(opts[:type]).to eq(:warn) if opts && opts.include?(:type)
          end
          @template.valid?
        end
      end

      describe "when AWS is configured" do

        let(:aws_error_message) { "The template is invalid" }

        before {
          Launcher::Config::AWS.stub(:configured?) { true }
          AWS::CloudFormation.any_instance.stub(:validate_template) {
            { :message => aws_error_message }
          }
        }

        it "should send the message" do
          @template.should_receive(:message).at_least(:once) do |msg, opts|
            expect(msg).to eq(aws_error_message)
          end
          @template.valid?
        end

        it { should_not be_valid }
      end
    end

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
