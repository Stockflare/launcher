require 'spec_helper'

require 'launcher/parameters'

describe Launcher::Parameters do

  before { @parameters = Launcher::Parameters.new }

  subject { @parameters }

  it { should respond_to(:outputs) }
  it { should respond_to(:params) }
  it { should respond_to(:configuration) }
  it { should respond_to(:all) }
  it { should respond_to(:[]) }
  it { should respond_to(:select) }

  describe "return value of #all" do

    let(:test_values) { { :foo => "bar", :x => "y" } }
    
    before { @parameters_with_values = Launcher::Parameters.new(test_values) }

    it "should be a hash" do
      expect(@parameters_with_values.all).to be_a(Hash)
    end

    it "should return the initialized values" do
      expect(@parameters_with_values.all).to eq(test_values)
    end
  end
  
end