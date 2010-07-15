describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
  end
  
  describe 'exclusion'
    before
      validations = {
        "string": {
          "exclusion": { "message": "is reserved", "in": [1,2,3] }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['exclusion'].should.eql([1,2,3])
      result.rules['object[string]']['required'].should.be_true
    end
  
    it 'should translate the message'
      result.messages['object[string]']['exclusion'].should.equal "is reserved"
      result.messages['object[string]']['required'].should.equal "is reserved"
    end
  end

  describe 'exclusion allow blank is false'
    before
      validations = {
        "string": {
          "exclusion": { "message":"is reserved", "in": [1,2,3], "allow_blank": false }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['exclusion'].should.eql([1,2,3])
      result.rules['object[string]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[string]']['exclusion'].should.equal "is reserved"
      result.messages['object[string]']['required'].should.equal "is reserved"
    end
  end

  describe 'exclusion allow blank is true'
    before
      validations = {
        "string": {
          "exclusion": { "message":"is reserved", "in": [1,2,3], "allow_blank": true }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['exclusion'].should.eql([1,2,3])
    end
    
    it 'should translate the message'
      result.messages['object[string]']['exclusion'].should.equal "is reserved"
    end
  end

end