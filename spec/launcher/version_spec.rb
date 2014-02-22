require 'spec_helper'

describe Launcher do

  it "should have a valid version number" do
    expect(Gem::Version.correct?(Launcher::VERSION)).to eq(0)
  end
  
end