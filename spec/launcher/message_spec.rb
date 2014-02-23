require 'spec_helper'

describe Launcher::Message do

  let(:test_message) { "This is a test message" }
  let(:test_options) { { :type => :ok } }
  let(:test_probe) { lambda() }

  let(:test_class) {
    class TestMessage
      include Launcher::Message
    end
  }

  before do 
    @message = test_class.new
    @message.message(test_message, test_options)
  end

  subject { @message }

  it { should respond_to(:messages) }
  it { should respond_to(:message) }

  describe "return value of #messages" do
    it "should return an array" do
      expect(@message.messages).to be_a(Array)
    end

    it "should have a positive length" do
      expect(@message.messages.length).to be > 0
    end

    it "should be an array of hashes" do
      expect(@message.messages.first).to be_a(Hash)
    end

    it "should contain an array of hashed messages" do
      expect(@message.messages.first[:message]).to eq(test_message)
    end
  end

  describe "when #messages is called with a block" do

    it "should call the block" do
      expect { |b| @message.messages(&b) }.to yield_control.once
    end

    it "should yield the message elements" do
      expected_options = test_options.merge(:message => test_message)
      expect { |b| @message.messages(&b) }.to yield_with_args(test_message, expected_options)
    end

  end

  it "should have a valid version number" do
    expect(Gem::Version.correct?(Launcher::VERSION)).to eq(0)
  end

  describe "when a class has a message handler bound" do
    it "should call the block when a message is added" do
      expect { |b|
        @message.message_handler &b
        @message.message(test_message, test_options)
        @message.message(test_message, test_options)
      }.to yield_control.twice
    end
  end
  
end