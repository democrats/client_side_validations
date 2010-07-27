shared_examples_for 'Numericality' do
  context 'Numericality' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number
        end
      
        @result = Klass.new.validate_options
      end
    
      it 'should translate the rule' do
        @result['rules']['number']['numericality'].should be_true
        @result['rules']['number']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['number']['numericality'].should == "is not a number"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  
    context 'allow blank is false' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :allow_blank => false
        end
      
        @result = Klass.new.validate_options
      end
    
      it 'should translate the rule' do
        @result['rules']['number']['numericality'].should be_true
        @result['rules']['number']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['number']['numericality'].should == "is not a number"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end

    context 'allow blank is true' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :allow_blank => true
        end
      
        @result = Klass.new.validate_options
      end
    
      it 'should translate the rule' do
        @result['rules']['number']['numericality'].should be_true
        @result['rules']['number']['required'].should be_nil
      end
    
      it 'should translate the message' do
        @result['messages']['number']['numericality'].should == "is not a number"
        @result['messages']['number']['required'].should be_nil
      end
    end
  end
    
  context 'Digits' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :only_integer => true
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
  end
  
  context 'Greater than' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :greater_than => 5
        end
        
        @result = Klass.new.validate_options
      end

      it 'should translate the rule' do
        @result['rules']['number']['greater_than'].should be_true
        @result['rules']['number']['required'].should be_true
      end

      it 'should translate the message' do
        @result['messages']['number']['greater_than'].should == "must be greater than 5"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  end

  context 'Greater than or equal to' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :greater_than_or_equal_to => 5
        end

        @result = Klass.new.validate_options
      end

      it 'should translate the rule' do
        @result['rules']['number']['min'].should be_true
        @result['rules']['number']['required'].should be_true
      end

      it 'should translate the message' do
        @result['messages']['number']['min'].should == "must be greater than or equal to 5"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  end

  context 'Less than' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :less_than => 5
        end

        @result = Klass.new.validate_options
      end

      it 'should translate the rule' do
        @result['rules']['number']['less_than'].should be_true
        @result['rules']['number']['required'].should be_true
      end

      it 'should translate the message' do
        @result['messages']['number']['less_than'].should == "must be less than 5"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  end

  context 'Less than or equal to' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :less_than_or_equal_to => 5
        end

        @result = Klass.new.validate_options
      end

      it 'should translate the rule' do
        @result['rules']['number']['max'].should be_true
        @result['rules']['number']['required'].should be_true
      end

      it 'should translate the message' do
        @result['messages']['number']['max'].should == "must be less than or equal to 5"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  end

  context 'Odd' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :odd => true
        end

        @result = Klass.new.validate_options
      end

      it 'should translate the rule' do
        @result['rules']['number']['odd'].should be_true
        @result['rules']['number']['required'].should be_true
      end

      it 'should translate the message' do
        @result['messages']['number']['odd'].should == "must be odd"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  end

  context 'Even' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_numericality_of :number, :even => true
        end

        @result = Klass.new.validate_options
      end

      it 'should translate the rule' do
        @result['rules']['number']['even'].should be_true
        @result['rules']['number']['required'].should be_true
      end

      it 'should translate the message' do
        @result['messages']['number']['even'].should == "must be even"
        @result['messages']['number']['required'].should == "is not a number"
      end
    end
  end

end