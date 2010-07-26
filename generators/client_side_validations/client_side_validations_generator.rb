class ClientSideValidationsGenerator < Rails::Generator::Base
  
  def initialize(runtime_args, runtime_options = {})
    runtime_options[:source] = File.join(spec.path, '../../javascript/lib')
    super
  end
  
  
  def manifest
    record do |c|
      c.directory('public/javascripts')
      c.file('client_side_validations.js', 'public/javascripts/client_side_validations.js')
      c.file('jquery-validation.js', 'public/javascripts/jquery-validation.js')
    end
  end
  
end
