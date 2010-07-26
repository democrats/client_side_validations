shared_examples_for 'Digits' do
  context 'Digits default' do
    before do
      Klass.class_eval do
        validates_numericality_of :number
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['number']['digits'].should be_true
      @result['rules']['number']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['number']['digits'].should == "is not a number"
      @result['messages']['number']['required'].should == "is not a number"
    end
  end
  
  context 'Digits allow blank is false' do
    before do
      Klass.class_eval do
        validates_numericality_of :number, :allow_blank => false
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['number']['digits'].should be_true
      @result['rules']['number']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['number']['digits'].should == "is not a number"
      @result['messages']['number']['required'].should == "is not a number"
    end
  end

  context 'Digits allow blank is true' do
    before do
      Klass.class_eval do
        validates_numericality_of :number, :allow_blank => true
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['number']['digits'].should be_true
      @result['rules']['number']['required'].should be_nil
    end
    
    it 'should translate the message' do
      @result['messages']['number']['digits'].should == "is not a number"
      @result['messages']['number']['required'].should be_nil
    end
  end
end