require 'rails/generators'

class ClientSideValidationsGenerator < Rails::Generators::Base
  
  def self.source_root
    File.join(File.dirname(__FILE__), '../../javascript/lib')
  end
  
  def install_client_side_validations
    copy_file('../../javascript/lib/client_side_validations.js',
      'public/javascripts/client_side_validations.js')
    copy_file('../../javascript/lib/jquery.validate.js',
      'public/javascripts/jquery.validate.js')
  end
end