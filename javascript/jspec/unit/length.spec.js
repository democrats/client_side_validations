describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
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

  describe 'range of length'
    before
      validations = {
        "string": {
          "length": {
            "message_max":"is too short (maximum is 10 characters)",
            "message_min":"is too short (minimum is 5 characters)",
            "maximum":10,
            "minimum":5
            }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['maxlength'].should.eql(10)
      result.rules['object[string]']['minlength'].should.eql(5)
    end
    
    it 'should translate the message'
      result.messages['object[string]']['maxlength'].should.equal "is too short (maximum is 10 characters)"
      result.messages['object[string]']['minlength'].should.equal "is too short (minimum is 5 characters)"
    end
  end

  describe 'range of length starting with a zero length'
    before
      validations = {
        "string": {
          "length": {
            "message_max":"is too short (maximum is 10 characters)",
            "message_min":"is too short (minimum is 0 characters)",
            "maximum":10,
            "minimum":0
            }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['maxlength'].should.eql(10)
      result.rules['object[string]']['minlength'].should.eql(0)
    end
    
    it 'should translate the message'
      result.messages['object[string]']['maxlength'].should.equal "is too short (maximum is 10 characters)"
      result.messages['object[string]']['minlength'].should.equal "is too short (minimum is 0 characters)"
    end
  end

end