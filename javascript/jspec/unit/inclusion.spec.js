describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
  end
  
  describe 'inclusion'
    before
      validations = {
        "string": {
          "inclusion": { "message": "is not included in the list", "in": [1,2,3] }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['inclusion'].should.eql([1,2,3])
      result.rules['object[string]']['required'].should.be_true
    end
  
    it 'should translate the message'
      result.messages['object[string]']['inclusion'].should.equal "is not included in the list"
      result.messages['object[string]']['required'].should.equal "is not included in the list"
    end
  end

  describe 'inclusion allow blank is false'
    before
      validations = {
        "string": {
          "inclusion": { "message":"is not included in the list", "in": [1,2,3], "allow_blank": false }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['inclusion'].should.eql([1,2,3])
      result.rules['object[string]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[string]']['inclusion'].should.equal "is not included in the list"
      result.messages['object[string]']['required'].should.equal "is not included in the list"
    end
  end

  describe 'inclusion allow blank is true'
    before
      validations = {
        "string": {
          "inclusion": { "message":"is not included in the list", "in": [1,2,3], "allow_blank": true }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['inclusion'].should.eql([1,2,3])
    end
    
    it 'should translate the message'
      result.messages['object[string]']['inclusion'].should.equal "is not included in the list"
    end
  end

end