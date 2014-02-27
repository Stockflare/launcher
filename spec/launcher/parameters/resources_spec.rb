require 'spec_helper'

require 'launcher/parameters/resources'

class MockCloudformationStackResource
  def logical_resource_id; "test_logical_id"; end
  def physical_resource_id; "test_physical_id"; end
end

class MockCloudformationStack 
  def resources; [MockCloudformationStackResource.new]; end
end

describe Launcher::Parameters::Resources do

  before { 
    Launcher::Config::AWS.stub(:configured?) { true }
    AWS::CloudFormation.any_instance.stub(:stacks) { [MockCloudformationStack.new] }
    @resources = Launcher::Parameters::Resources.new
  }

  subject { @resources }

  it "should return a hash" do
    expect(@resources).to be_a(Hash)
  end

  it "should contain test resources" do
    expect(@resources.keys).to_not be_empty
  end

  it "should contain the test resource keys" do
    expect(@resources.keys).to eq(["test_logical_id"])
  end

  it "should contain the test resource values" do
    expect(@resources.values).to eq(["test_physical_id"])
  end

end