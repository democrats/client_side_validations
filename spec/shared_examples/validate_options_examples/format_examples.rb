shared_examples_for 'Format' do
  context 'Format default' do
    before do
      Klass.class_eval do
        validates_format_of :string, :with => /\w/
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['string']['format'].should == /\w/
      @result['rules']['string']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['string']['format'].should == "is invalid"
      @result['messages']['string']['required'].should == "is invalid"
    end
  end
  
  context 'Format allow blank is false' do
    before do
      Klass.class_eval do
        validates_format_of :string, :with => /\w/
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['string']['format'].should == /\w/
      @result['rules']['string']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['string']['format'].should == "is invalid"
      @result['messages']['string']['required'].should == "is invalid"
    end
  end

  context 'Format allow blank is true' do
    before do
      Klass.class_eval do
        validates_format_of :string, :with => /\w/, :allow_blank => true
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['string']['format'].should == /\w/
      @result['rules']['string']['required'].should be_nil
    end
    
    it 'should translate the message' do
      @result['messages']['string']['format'].should == "is invalid"
      @result['messages']['string']['required'].should be_nil
    end
  end
end