describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'http://someurl.com/books.js', 'jquery.validate');
  end
  
  describe 'required'
    before
      validations = {
        "number": { 
          "presence": { "message":"can't be blank" }
        }
      }
      result = client.adaptValidations(validations);
    end
  
    it 'should translate the rule'
      result.rules['object[number]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[number]']['required'].should.equal "can't be blank"
    end
  end
  
  describe 'format'
    before
      validations = {
        "number": {
          "format": { "message":"is invalid", "with":/\d/ }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[number]']['format'].should.eql(/\d/)
    end
    
    it 'should translate the message'
      result.messages['object[number]']['format'].should.equal "is invalid"
    end
  end

  describe 'digits'
    before
      validations = {
        "number": {
          "numericality": { "message":"is not a number" }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[number]']['digits'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[number]']['digits'].should.equal "is not a number"
    end
  end

  describe 'minlength'
    before
      validations = {
        "string": {
          "length": { "message":"is too short (minimum is 10 characters)", "minimum":10 }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['minlength'].should.eql(10)
    end
    
    it 'should translate the message'
      result.messages['object[string]']['minlength'].should.equal "is too short (minimum is 10 characters)"
    end
  end
  
  describe 'maxlength'
    before
      validations = {
        "string": {
          "length": { "message":"is too short (maximum is 10 characters)", "maximum":10 }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['maxlength'].should.eql(10)
    end
    
    it 'should translate the message'
      result.messages['object[string]']['maxlength'].should.equal "is too short (maximum is 10 characters)"
    end
  end
  
  describe 'multiple attributes'
    before
      validations = {
        "number_1": { 
          "presence": { "message":"can't be blank" }
        },
        "number_2": { 
          "presence": { "message":"can't be blank" }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rules for both attributes'
      result.rules['object[number_1]']['required'].should.be_true
      result.rules['object[number_2]']['required'].should.be_true
    end
    
    it 'should translate the messages for both attributes'
      result.messages['object[number_1]']['required'].should.eql("can't be blank")
      result.messages['object[number_2]']['required'].should.eql("can't be blank")
    end
  end

  describe 'multiple rules'
    before
      validations = {
        "number": { 
          "presence": { "message":"can't be blank" },
          "numericality": { "message":"is not a number" }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rules for both attributes'
      result.rules['object[number]']['required'].should.be_true
      result.rules['object[number]']['digits'].should.be_true
    end
    
    it 'should translate the messages for both attributes'
      result.messages['object[number]']['required'].should.eql("can't be blank")
      result.messages['object[number]']['digits'].should.eql("is not a number")
    end
  end
end