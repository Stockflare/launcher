require 'spec_helper'

require 'launcher/parameters'

describe Launcher::Parameters do

  let(:test_values) { { :foo => "bar", :x => "y" } }

  before do
    Launcher::Config::AWS.stub(:configured?) { false }
    Launcher::Config(:params => test_values)
    @parameters_with_values = Launcher::Parameters.new
  end

  after { Launcher::Config.delete!(:params) }

  subject { @parameters_with_values }

  it { should respond_to(:[]) }
  it { should respond_to(:select) }
  it { should respond_to(:filter) }
  it { should respond_to(:filtered?) }

  it { should be_a_kind_of(Hash) }

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

  describe "return value of #filter" do
    describe "when a filter is defined" do

      before { Launcher::Config(:filter => 'fo+') }
      after { Launcher::Config.delete!(:filter) }

      it "should return a regular expression" do
        expect(@parameters_with_values.filter).to be_a(Regexp)
      end

    end

    describe "when a filter is not defined" do
      it "should return nil" do
        expect(@parameters_with_values.filter).to be_nil
      end
    end
  end

  describe "return value of #filtered?" do
    describe "when a filter is defined" do

      before { Launcher::Config(:filter => '\Afr[a-z]nce?\Z') }
      after { Launcher::Config.delete!(:filter) }

      it "should not filter out a matching key" do
        expect(@parameters_with_values.filtered?('franc')).to be_falsey
      end

      it "should filter a non-matching key" do
        expect(@parameters_with_values.filtered?('fr0nce')).to be_truthy
      end

    end

    describe "when a filter is not defined" do
      it "should not filter out any keys" do
        expect(@parameters_with_values.filtered?('franc')).to be_falsey
      end
    end
  end

end
