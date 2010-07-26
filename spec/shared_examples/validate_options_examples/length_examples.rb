shared_examples_for 'Length' do
  context 'Islength' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_length_of :string, :is => 5
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['islength'].should == 5
        @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['islength'].should == "is the wrong length (should be 5 characters)"
        @result['messages']['string']['required'].should == "is the wrong length (should be 5 characters)"
      end
    end

    context 'allow_blank is false' do
      before do
        Klass.class_eval do
          validates_length_of :string, :is => 5, :allow_blank => false
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['islength'].should == 5
        @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['islength'].should == "is the wrong length (should be 5 characters)"
        @result['messages']['string']['required'].should == "is the wrong length (should be 5 characters)"
      end
    end

    context 'allow_blank is true' do
      before do
        Klass.class_eval do
          validates_length_of :string, :is => 5, :allow_blank => true
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['islength'].should == 5
        @result['rules']['string']['required'].should be_nil
      end
    
      it 'should translate the message' do
        @result['messages']['string']['islength'].should == "is the wrong length (should be 5 characters)"
        @result['messages']['string']['required'].should be_nil
      end
    end
  end
  
  context 'Minlength' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_length_of :string, :minimum => 5
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['minlength'].should == 5
        @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['minlength'].should == "is too short (minimum is 5 characters)"
        @result['messages']['string']['required'].should == "is too short (minimum is 5 characters)"
      end
    end

    context 'allow_blank is false' do
      before do
        Klass.class_eval do
          validates_length_of :string, :minimum => 5, :allow_blank => false
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['minlength'].should == 5
        @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['minlength'].should == "is too short (minimum is 5 characters)"
        @result['messages']['string']['required'].should == "is too short (minimum is 5 characters)"
      end
    end

    context 'allow_blank is true' do
      before do
        Klass.class_eval do
          validates_length_of :string, :minimum => 5, :allow_blank => true
        end
      
        @result = Klass.new.validate_options
      end
      it 'should translate the rule' do
        @result['rules']['string']['minlength'].should == 5
        @result['rules']['string']['required'].should be_nil
      end
    
      it 'should translate the message' do
        @result['messages']['string']['minlength'].should == "is too short (minimum is 5 characters)"
        @result['messages']['string']['required'].should be_nil
      end
    end
  end

  context 'Maxlength' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_length_of :string, :maximum => 10
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['maxlength'].should == 10
       # @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['maxlength'].should == "is too long (maximum is 10 characters)"
       # @result['messages']['string']['required'].should == "is too long (maximum is 10 characters)"
      end
    end
  
    context 'allow_blank is false' do
      before do
        Klass.class_eval do
          validates_length_of :string, :maximum => 10, :allow_blank => false
        end
      
        @result = Klass.new.validate_options
      end
      it 'should translate the rule' do
        @result['rules']['string']['maxlength'].should == 10
       # @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['maxlength'].should == "is too long (maximum is 10 characters)"
       # @result['messages']['string']['required'].should == "is too long (maximum is 10 characters)"
      end
    end
  
    context 'allow_blank is true' do
      before do
        Klass.class_eval do
          validates_length_of :string, :maximum => 10, :allow_blank => true
        end
      
        @result = Klass.new.validate_options
      end
      
      it 'should translate the rule' do
        @result['rules']['string']['maxlength'].should == 10
       # @result['rules']['string']['required'].should be_nil
      end
    
      it 'should translate the message' do
        @result['messages']['string']['maxlength'].should == "is too long (maximum is 10 characters)"
       # @result['messages']['string']['required'].should be_nil
      end
    end
  end
  
  context 'Range' do
    context 'default' do
      before do
        Klass.class_eval do
          validates_length_of :string, :within => 5..10
        end
      
        @result = Klass.new.validate_options
      end
  
      it 'should translate the rule' do
        @result['rules']['string']['minlength'].should == 5
        @result['rules']['string']['maxlength'].should == 10
        @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['minlength'].should == "is too short (minimum is 5 characters)"
        @result['messages']['string']['maxlength'].should == "is too long (maximum is 10 characters)"
        @result['messages']['string']['required'].should == "is too short (minimum is 5 characters)"
      end
    end
  
    context 'allow_blank is false' do
      before do
        Klass.class_eval do
          validates_length_of :string, :within => 5..10, :allow_blank => false
        end
      
        @result = Klass.new.validate_options
      end
  
      it 'should translate the rule' do
        @result['rules']['string']['minlength'].should == 5
        @result['rules']['string']['maxlength'].should == 10
        @result['rules']['string']['required'].should be_true
      end
    
      it 'should translate the message' do
        @result['messages']['string']['minlength'].should == "is too short (minimum is 5 characters)"
        @result['messages']['string']['maxlength'].should == "is too long (maximum is 10 characters)"
        @result['messages']['string']['required'].should == "is too short (minimum is 5 characters)"
      end
    end
  
    context 'allow_blank is true' do
      before do
        Klass.class_eval do
          validates_length_of :string, :within => 5..10, :allow_blank => true
        end
      
        @result = Klass.new.validate_options
      end
  
      it 'should translate the rule' do
        @result['rules']['string']['minlength'].should == 5
        @result['rules']['string']['maxlength'].should == 10
        @result['rules']['string']['required'].should be_nil
      end
    
      it 'should translate the message' do
        @result['messages']['string']['minlength'].should == "is too short (minimum is 5 characters)"
        @result['messages']['string']['maxlength'].should == "is too long (maximum is 10 characters)"
        @result['messages']['string']['required'].should be_nil
      end
    end
  end

end