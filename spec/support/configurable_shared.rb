shared_examples "a class that stores configuration" do |*args|

  it { should respond_to(:options) }

  let(:test_hash) { { :foo => "bar" } }

  context "when there are defaulted options" do

    let(:class_with_defaults) { 
      Launcher::Config(test_hash)
      described_class do
        options test_hash
      end 

      described_class.new(*args)
    }

    it "should not contain a nil value" do
      expect(class_with_defaults.options(:foo)).to_not be_nil
    end

  end

  describe "when there is an optional option" do

    let(:class_with_optional_option) {
      described_class do
        options :boo
      end 
      described_class.new(*args)
    }

    it "should return an empty option" do
      expect(class_with_optional_option.options(:boo)).to be_nil
    end
  end

  describe "when there is a mix of options" do
    let(:class_with_mixed_options) {
      Launcher::Config(test_hash)
      described_class do
        options :boo, test_hash
      end 

      described_class.new(*args)
    }

    it "should return a defaulted option" do
      expect(class_with_mixed_options.options(test_hash.keys.first)).to eq(test_hash.values.first)
    end

    it "should return an empty optional option" do
      expect(class_with_mixed_options.options(:boo)).to be_nil
    end
  end

end