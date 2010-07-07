require 'rubygems'
require 'json'
require 'cgi'

class ClientSideValidations
  def initialize(app)
    @app = app
  end
  
  def call(env)
    params = CGI::parse(env['QUERY_STRING'])
    case env['PATH_INFO']
    when %r{^/validations.json}
      body = get_validations(params['model'][0])
      [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, body]
    when %r{^/validations/uniqueness.json}
      field               = params.keys.first
      resource, attribute = field.split(/[^\w]/)
      value               = params[field][0]
      body                = is_unique?(resource, attribute, value).to_s
      [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, body]
    else
      @app.call(env)
    end
  end
  
  private
  
  def get_validations(resource)
    constantize_resource(resource).new.validations_to_json
  end
  
  def is_unique?(resource, attribute, value)
    constantize_resource(resource).send("find_by_#{attribute}", value) == nil
  end
  
  def constantize_resource(resource)
    eval(resource.split('_').map{ |word| word.capitalize}.join)
  end
  
end

require 'client_side_validations/orm'
require 'client_side_validations/template'