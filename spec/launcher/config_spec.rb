require 'spec_helper'

describe Launcher::Config do

  let(:test_data) { { :a => "a", :b => "b"} }

  before(:each) { Launcher::Config(test_data) }

  it "should be present" do
    expect(subject).to_not be_nil
  end

  it "should accept new values" do
    subject[:new_value] = true
    expect(subject[:new_value]).to equal(true)
  end

  it "should modify existing values" do
    subject[:a] = "a new value"
    expect(subject[:a]).to_not equal(test_data[:a])
  end

  it "should retrieve a single value" do
    expect(subject[:a]).to equal(test_data[:a])
  end

  it "should retrieve sets of values" do
    subject.select(*test_data.keys).should == test_data
  end

  it "should return nothing for a non-existing value" do
    expect(subject.select(:non_existing_key)).to be_empty
  end

  it "should delete a key" do
    Launcher::Config.delete!(:a)
    expect(subject.select(:a, :b)).to eq({:b => "b"})
  end

end