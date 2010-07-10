require 'spec_helper'
require 'client_side_validations'

describe 'Default Options' do
  before do
    @options = { :test => 'This' }
  end
  
  context 'setter / getter' do
    before do
      ClientSideValidations.default_options = @options
    end
    
    it 'should set the default options' do
      ClientSideValidations.default_options.should == @options
    end
  end
  
end