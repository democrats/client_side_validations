describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
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

end