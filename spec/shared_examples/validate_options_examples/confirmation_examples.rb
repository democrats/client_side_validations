shared_examples_for 'Confirmation' do
  context 'Confirmation default' do
    before do
      Klass.class_eval do
        validates_confirmation_of :string
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['string']['confirmation'].should == true
    end
    
    it 'should translate the message' do
      @result['messages']['string']['confirmation'].should == "doesn't match confirmation"
    end
  end
end