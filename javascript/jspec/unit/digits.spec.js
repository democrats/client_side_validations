describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
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
      result.rules['object[number]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[number]']['digits'].should.equal "is not a number"
      result.messages['object[number]']['required'].should.equal "is not a number"
    end
  end

  describe 'digits allow blank is false'
    before
      validations = {
        "number": {
          "numericality": { "message":"is not a number", "with":/\d/, "allow_blank": false }
        }
      }
      result = client.adaptValidations(validations)
    end
    
    it 'should translate the rule'
      result.rules['object[number]']['digits'].should.be_true
      result.rules['object[number]']['required'].should.be_true
    end
    
    it 'should translate the message'
      result.messages['object[number]']['digits'].should.equal "is not a number"
      result.messages['object[number]']['required'].should.equal "is not a number"
    end
  end

  describe 'digits allow blank is true'
    before
      validations = {
        "number": {
          "numericality": { "message":"is not a number", "with":/\d/, "allow_blank": true }
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

end