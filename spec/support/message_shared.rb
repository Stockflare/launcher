shared_examples "a class that stores messages" do

  let(:test_message) { "This is a test message" }
  let(:test_options) { { :type => :ok } }

  before do 
    subject.message(test_message, test_options)
  end

  it { should respond_to(:messages) }
  it { should respond_to(:message) }

  describe "return value of #messages" do
    it "should return an array" do
      expect(subject.messages).to be_a(Array)
    end

    it "should have a positive length" do
      expect(subject.messages.length).to be > 0
    end

    it "should be an array of hashes" do
      expect(subject.messages.first).to be_a(Hash)
    end

    it "should contain an array of hashed messages" do
      expect(subject.messages.first[:message]).to eq(test_message)
    end
  end

  describe "when #messages is called with a block" do

    it "should call the block" do
      expect { |b| subject.messages(&b) }.to yield_control.once
    end

    it "should yield the message elements" do
      expected_options = test_options.merge(:message => test_message)
      expect { |b| subject.messages(&b) }.to yield_with_args(test_message, expected_options)
    end

  end

  describe "when a class has a message handler bound" do
    it "should call the block when a message is added" do
      expect { |b|
        subject.message_handler &b
        subject.message(test_message, test_options)
        subject.message(test_message, test_options)
      }.to yield_control.twice
    end
  end
  
end