describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
  end
  
  describe 'uniqueness'
    before
      validations = {
        "string": {
          "uniqueness": { "message": "has already been taken" }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['remote'].should.eql({url:'/validations/uniqueness.json',data:{}})
    end
  
    it 'should translate the message'
      result.messages['object[string]']['remote'].should.equal "has already been taken"
    end
  end

  describe 'uniqueness allow blank is false'
    before
      validations = {
        "string": {
          "uniqueness": { "message": "has already been taken", 'allow_blank': false }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['remote'].should.eql({url:'/validations/uniqueness.json',data:{}})
      result.rules['object[string]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[string]']['remote'].should.equal "has already been taken"
      result.messages['object[string]']['required'].should.equal "has already been taken"
    end
  end

  describe 'uniqueness allow blank is true'
    before
      validations = {
        "string": {
          "uniqueness": { "message": "has already been taken", 'allow_blank': true }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['remote'].should.eql({url:'/validations/uniqueness.json',data:{}})
    end
    
    it 'should translate the message'
      result.messages['object[string]']['remote'].should.equal "has already been taken"
    end
  end

end