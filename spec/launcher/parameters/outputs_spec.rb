require 'spec_helper'

require 'launcher/parameters/outputs'

class MockCloudformationStackOutput
  def key; "foo"; end
  def value; "bar"; end
end

class MockCloudformationStack 
  def outputs; [MockCloudformationStackOutput.new]; end
end

describe Launcher::Parameters::Outputs do

  before { 
    Launcher::Config::AWS.stub(:configured?) { true }
    AWS::CloudFormation.any_instance.stub(:stacks) { [MockCloudformationStack.new] }
    @outputs = Launcher::Parameters::Outputs.new
  }

  subject { @outputs }

  it "should return a hash" do
    expect(@outputs).to be_a(Hash)
  end

  it "should contain test outputs" do
    expect(@outputs.keys).to_not be_empty
  end

  it "should contain the test resource keys" do
    expect(@outputs.keys).to eq([:foo])
  end

  it "should contain the test resource values" do
    expect(@outputs.values).to eq(["bar"])
  end

end