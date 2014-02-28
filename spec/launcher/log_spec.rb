require 'spec_helper'

require 'launcher/log'

describe Launcher::Log do

  it { Launcher::Log.should respond_to(:debug) }
  it { Launcher::Log.should respond_to(:error) }
  it { Launcher::Log.should respond_to(:info) }
  it { Launcher::Log.should respond_to(:warn) }
  it { Launcher::Log.should respond_to(:fatal) }
  it { Launcher::Log.should respond_to(:ok) }

  describe "return value of #format_msg" do

    let(:severity) { "ERROR" }
    let(:msg) { "This is a test message" }
    let(:time) { Time.now }

    it "should return a correctly formatted message" do
      message = Launcher::Log.format_msg(severity, msg, time)
      expected_message = "[#{time}] [#{severity}]: #{msg}\n"
      expect(message).to eq(expected_message)
    end

  end

  describe "action of #color" do

    let(:message) { "a message" }
    let(:type) { :fatal }

    it "should retrieve the correct color for a message" do
      Launcher::Log.should_receive(:color_fatal).with(message)
      Launcher::Log.color(message, type)
    end

    it "should correctly stylize a message" do
      expect(Launcher::Log.color(message,type)).to eq(message.underline.red)
    end
    
  end
  
end