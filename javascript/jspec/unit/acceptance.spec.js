describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
  end
  
  describe 'acceptance'
    before
      validations = {
        "string": {
          "acceptance": { "message": "must be accepted" }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['acceptance'].should.be_true
    end
  
    it 'should translate the message'
      result.messages['object[string]']['acceptance'].should.equal "must be accepted"
    end
  end

end