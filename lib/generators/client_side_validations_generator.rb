require 'rails/generators'

class ClientSideValidationsGenerator < Rails::Generators::Base
  
  def self.source_root
    File.join(File.dirname(__FILE__), '../../jaascript/lib')
  end
  
  def install_client_side_validations
    copy_file('../../javascript/lib/client_side_validations.js',
      'public/javascripts/client_side_validations.js')
  end
end