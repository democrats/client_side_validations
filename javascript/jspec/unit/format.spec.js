describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
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
      result.rules['object[number]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[number]']['format'].should.equal "is invalid"
      result.messages['object[number]']['required'].should.equal "is invalid"
    end
  end

  describe 'format allow blank is false'
    before
      validations = {
        "number": {
          "format": { "message":"is invalid", "with":/\d/, "allow_blank": false }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[number]']['format'].should.eql(/\d/)
      result.rules['object[number]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[number]']['format'].should.equal "is invalid"
      result.messages['object[number]']['required'].should.equal "is invalid"
    end
  end

  describe 'format allow blank is true'
    before
      validations = {
        "number": {
          "format": { "message":"is invalid", "with":/\d/, "allow_blank": true }
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

end