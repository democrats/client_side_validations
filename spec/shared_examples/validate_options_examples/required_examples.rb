shared_examples_for 'Required' do
  context 'Required default' do
    before do
      Klass.class_eval do
        validates_presence_of :string
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['string']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['string']['required'].should == "can't be blank"
    end
  end
end