require 'spec_helper'

require "launcher/config"
require "launcher/config/aws"

describe Launcher::Config::AWS do

  let(:test_data) { { access_key_id: "aki", secret_access_key: "sak", region: 'us-east-1' } }

  after { Launcher::Config.reset! }

  it { should respond_to(:configuration) }

  it { should respond_to(:credentials) }

  it { should respond_to(:region) }

  describe 'return value of #[]' do

    before { Launcher::Config(test_data) }

    subject { Launcher::Config::AWS[test_data.keys.sample] }

    it { should be_a String }

    it { should_not be_empty }

    specify { expect(test_data.values).to include subject }

  end

  describe 'return value of #configuration with a profile' do

    before { Launcher::Config(profile: 'test') }

    subject { Launcher::Config::AWS.configuration }

    describe 'nested credentials' do

      subject { Launcher::Config::AWS.configuration[:credentials] }

      it { should be_an_instance_of Aws::SharedCredentials }

      specify { expect(subject.loadable?).to be_falsey }

    end

  end

  describe 'return value of #configuration with keys' do

    before { Launcher::Config(test_data) }

    subject { Launcher::Config::AWS.configuration }

    it { should be_a Hash }

    it { should_not be_empty }

    describe 'nested credentials' do

      subject { Launcher::Config::AWS.configuration[:credentials] }

      it { should be_an_instance_of Aws::Credentials }

      specify { expect(subject.access_key_id).to eq test_data[:access_key_id] }

      specify { expect(subject.secret_access_key).to eq test_data[:secret_access_key] }

    end

    describe 'nested region' do

      subject { Launcher::Config::AWS.configuration[:region] }

      it { should be_a String }

      it { should eq test_data[:region] }

    end


  end

end
