describe 'jQuery Client Side Validations'
  describe 'adapters'
    describe 'jquery.validate'
      describe 'required'
        before
          validations = {
            "number": { 
              "presence": { "message":"can't be blank" }
            }
          }
          result = jQueryValidateAdapter('object', validations);
        end
      
        it 'should translate the rule'
          result.rules['object[number]']['required'].should.be_true
        end
        
        it 'should translate the message'
          result.messages['object[number]']['required'].should.equal "can't be blank"
        end
      end
      
      describe 'format'
        before
          validations = {
            "number": {
              "format": { "message":"is invalid", "with":/\d/ }
            }
          }
          result = jQueryValidateAdapter('object', validations)
        end
        
        it 'should translate the rule'
          result.rules['object[number]']['format'].should.eql(/\d/)
        end
        
        it 'should translate the message'
          result.messages['object[number]']['format'].should.equal "is invalid"
        end
      end
    end
  end
end