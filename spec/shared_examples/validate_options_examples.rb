shared_examples_for 'Validate Options' do
  context 'simple rule and message conversions' do
    it "should support a single validation" do
      Klass.class_eval do
        validates_presence_of :string
      end

      instance          = Klass.new
      expected_rules    = {'string' => {'required' => true}}
      expected_messages = {'string' => {'required' => "can't be blank"}}
      expectation       = {'rules' => expected_rules, 'messages' => expected_messages}
      result            = instance.validate_options
      result.should == expectation
    end

    it "should support multiple validations on the same field" do
      Klass.class_eval do
        validates_presence_of     :number
        validates_numericality_of :number
      end

      instance          = Klass.new
      expected_rules    = {'number' => {'required' => true, 'digits' => true}}
      expected_messages = {'number' => {'required' => "can't be blank", 'digits' => "is not a number"}}
      expectation       = {'rules' => expected_rules, 'messages' => expected_messages}
      result            = instance.validate_options
      result.should == expectation
    end

    it "should support single validations on different fields" do
      Klass.class_eval do
        validates_presence_of :string_1
        validates_presence_of :string_2
      end

      instance          = Klass.new
      expected_rules    = {'string_1' => {'required' => true}, 'string_2' => {'required' => true}}
      expected_messages = {'string_1' => {'required' => "can't be blank"}, 'string_2' => {'required' => "can't be blank"}}
      expectation       = {'rules' => expected_rules, 'messages' => expected_messages}
      result            = instance.validate_options
      result.should == expectation
    end

    it "should support multiple validations on different fields" do
      Klass.class_eval do
        validates_presence_of     :number_1
        validates_numericality_of :number_1
        validates_presence_of     :number_2
        validates_numericality_of :number_2
      end

      instance          = Klass.new
      expected_rules    = {'number_1' => {'required' => true, 'digits' => true}, 'number_2' => {'required' => true, 'digits' => true}}
      expected_messages = {'number_1' => {'required' => "can't be blank", 'digits' => "is not a number"}, 'number_2' => {'required' => "can't be blank", 'digits' => "is not a number"}}
      expectation       = {'rules' => expected_rules, 'messages' => expected_messages}
      result            = instance.validate_options
      result.should == expectation
    end
  end
  
  %w{Acceptance Confirmation Digits Exclusion Inclusion Length Required Uniqueness}.each do |example|
    it_should_behave_like example
  end
  
end