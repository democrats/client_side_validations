shared_examples_for 'Acceptance' do
  context 'Acceptance default' do
    before do
      Klass.class_eval do
        validates_acceptance_of :string
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['string']['acceptance'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['string']['acceptance'].should == 'must be accepted'
    end
  end
end