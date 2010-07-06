require 'client_side_validations'
require 'spec_helper'
require 'rack/test'
require 'crack/json'

describe 'Client Side Validations Middleware' do
  include Rack::Test::Methods
  
  def app
    app = Proc.new {|env| [200,{},"successfully hit rails app"]}
    ClientSideValidations.new(app)
  end
  
  context 'multiple resources' do
    before do
      class Book; end
      class PartnerUser; end
    end
    
    describe 'rules' do
      it 'should generate a rules path for the book resource' do
        Book.any_instance.stubs(:validations_to_json).returns("VALIDATIONS_TO_JSON")
        get '/book/validations.json'
        last_response.body.should == "VALIDATIONS_TO_JSON"
      end
    
      it 'should generate a rules path for the partner_user resource' do
        PartnerUser.any_instance.stubs(:validations_to_json).returns("VALIDATIONS_TO_JSON")
        get '/partner_user/validations.json'
        last_response.body.should == "VALIDATIONS_TO_JSON"
      end
    end
    
    describe 'uniqueness' do
      it 'should generate a uniqueness path for the book resource' do
        Book.stubs(:find_by_name).returns(nil)
        get '/book/validations/uniqueness/name.json', { :value => 'Test' }
        Crack::JSON.parse(last_response.body).should == {"unique" => true}
      end

      it 'should generate a uniqueness path for the partner_user resource' do
        PartnerUser.stubs(:find_by_name).returns("Found a record")
        get '/partner_user/validations/uniqueness/name.json', { :value => 'Test' }
        Crack::JSON.parse(last_response.body).should == {"unique" => false}
      end
    end
  end
end