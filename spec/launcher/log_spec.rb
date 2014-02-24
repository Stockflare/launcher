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

  end
  
end