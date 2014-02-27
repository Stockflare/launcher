require 'spec_helper'

require 'launcher/parameters'

describe Launcher::Parameters do

  let(:test_values) { { :foo => "bar", :x => "y" } }

  before do
    Launcher::Config::AWS.stub(:configured?) { false }
    @parameters = build(:parameters)
    @parameters_with_values = Launcher::Parameters.new(test_values)
  end

  subject { @parameters }

  it { should respond_to(:outputs) }
  it { should respond_to(:params) }
  it { should respond_to(:configuration) }
  it { should respond_to(:all) }
  it { should respond_to(:[]) }
  it { should respond_to(:select) }

  describe "return value of #all" do
    
    it "should be a hash" do
      expect(@parameters_with_values.all).to be_a(Hash)
    end

    it "should return the initialized values" do
      expect(@parameters_with_values.all).to eq(test_values)
    end
  end

  describe "return value of #[](key)" do

    describe "when a key exists" do
      it "should return the value" do
        expect(@parameters_with_values[:foo]).to eq("bar")
      end
    end

    describe "when a key does not exist" do
      it "should return the value" do
        expect(@parameters_with_values[:boo]).to be_nil
      end
    end

  end

  describe "return value of #select" do

    it "should be a hash" do
      expect(@parameters_with_values.select(:foo, :bar)).to be_a(Hash)
    end

    it "should match the keys defined" do
      expect(@parameters_with_values.select(*test_values.keys).keys).to eq test_values.keys
    end

    it "should return a hash of the keys and values defined" do
      expect(@parameters_with_values.select(*test_values.keys)).to eq test_values
    end

  end
  
end