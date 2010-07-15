describe 'jquery.validate adapter'
  before
    client = new ClientSideValidations('object', 'jquery.validate');
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
          "numericality": { "message":"is not a number" },
          "presence": { "message":"can't be blank" }
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