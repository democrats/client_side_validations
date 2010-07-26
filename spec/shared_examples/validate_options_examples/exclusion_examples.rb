shared_examples_for 'Exclusion' do
  context 'Exclusion default' do
    before do
      Klass.class_eval do
        validates_exclusion_of :number, :in => [1,2,3]
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['number']['exclusion'].should == [1,2,3]
      @result['rules']['number']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['number']['exclusion'].should == "is reserved"
      @result['messages']['number']['required'].should == "is reserved"
    end
  end
  
  context 'Exclusion allow blank is false' do
    before do
      Klass.class_eval do
        validates_exclusion_of :number, :in => [1,2,3], :allow_blank => false
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['number']['exclusion'].should == [1,2,3]
      @result['rules']['number']['required'].should be_true
    end
    
    it 'should translate the message' do
      @result['messages']['number']['exclusion'].should == "is reserved"
      @result['messages']['number']['required'].should == "is reserved"
    end
  end

  context 'Exclusion allow blank is true' do
    before do
      Klass.class_eval do
        validates_exclusion_of :number, :in => [1,2,3], :allow_blank => true
      end
      
      @result = Klass.new.validate_options
    end
    
    it 'should translate the rule' do
      @result['rules']['number']['exclusion'].should == [1,2,3]
      @result['rules']['number']['required'].should be_nil
    end
    
    it 'should translate the message' do
      @result['messages']['number']['exclusion'].should == "is reserved"
      @result['messages']['number']['required'].should be_nil
    end
  end
end