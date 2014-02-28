require 'spec_helper'

require 'launcher/parameters/options'

describe Launcher::Parameters::Options do

  let(:test_values) { { :foo => "bar" } }

  before { 
    Launcher::Config(:params => test_values) 
    @options = Launcher::Parameters::Options.new
  }

  subject { @options }

  it { should be_kind_of(Hash) }

  after { Launcher::Config.delete!(:params) }

  describe "when options are defined" do
    it "should return the options" do
      expect(@options).to eq(test_values)
    end
  end

  describe "when no options are defined" do
    before { Launcher::Config.delete!(:params) }
    it "should return an empty option set" do
      expect(Launcher::Parameters::Options.new).to eq({})
    end
  end

  describe "when a different key is passed" do

    let(:other_test_values) { { :saving => "private_ryan" } }

    before {
      Launcher::Config(:another_key => other_test_values) 
      @another_options = Launcher::Parameters::Options.new(:another_key)
    }

    after { Launcher::Config.delete!(:another_key) }

    it "should return the expected options" do
      expect(@another_options).to eq(other_test_values)
    end

  end

end