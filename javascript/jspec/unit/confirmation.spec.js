describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
  end

  describe 'confirmation'
    before
      validations = {
        "string": {
          "confirmation": { "message": "doesn't match confirmation" }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[string]']['equalTo'].should.eql("[name='object[string_confirmation]']")
    end
  
    it 'should translate the message'
      result.messages['object[string]']['equalTo'].should.equal "doesn't match confirmation"
    end
  end

end