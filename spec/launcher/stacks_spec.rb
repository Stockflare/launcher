require 'spec_helper'

require 'launcher/stacks'

class MockCloudformationStack 
  def name; "Test"; end
  def status; "CREATE_COMPLETE"; end
  def updated_at; Time.now; end
  def last_updated_time; Time.now; end
  def status_reason; "Created"; end
end

describe Launcher::Stacks do

  before { 

    class Array
      def each_batch(&block); block.call(self); end 
    end

    Launcher::Config::AWS.stub(:configured?) { true }
    @stack = MockCloudformationStack.new
    AWS::CloudFormation.any_instance.stub(:stacks) { [@stack] }
    @stacks = Launcher::Stacks.new
  }

  subject { @stacks }

  it { should respond_to(:each) }
  it { should respond_to(:all) }
  it { should respond_to(:all_statuses) }

  it { should be_kind_of(Launcher::Message) }
  it_behaves_like "a class that stores messages"

  describe "return value of #all" do
    it "should be an array" do
      expect(@stacks.all).to be_a(Array)
    end

    it "should not be empty" do
      expect(@stacks.all).to_not be_empty
    end

    it "should contain a stack" do
      expect(@stacks.all).to eq([@stack])
    end

    it "should iterate over stacks" do
      expect { |b| @stacks.all.each &b }.to yield_control.at_least(1)
    end
  end

  describe "when stacks are iterated over" do
    it "should call a block" do
      expect { |b| @stacks.each &b }.to yield_control.at_least(1)
    end

    it "should pass a stack to a block" do
      expect { |b| @stacks.each &b }.to yield_with_args(@stack)
    end
  end

  describe "when all statuses are retrieved" do
    it "should return an array" do
      expect(@stacks.all_statuses).to be_a(Array)
    end

    it "should not be empty" do
      expect(@stacks.all_statuses).to_not be_empty
    end

    it "should call a block" do
      expect { |b| @stacks.all_statuses &b }.to yield_control.at_least(1)
    end
  end

end