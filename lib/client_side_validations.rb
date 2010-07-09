require 'rubygems'
require 'json'
require 'cgi'

class ClientSideValidations
  def initialize(app)
    @app = app
  end
  
  def call(env)
    # By default CGI::parse will instantize a hash that defaults nil elements to [].
    # We need to override this
    params = {}.merge!(CGI::parse(env['QUERY_STRING']))
    case env['PATH_INFO']
    when %r{^/validations.json}
      body = get_validations(params['model'][0])
      [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, body]
    when %r{^/validations/uniqueness.json}
      field               = params.keys.first
      resource, attribute = field.split(/[^\w]/)
      value               = params[field][0]
      # Because params returns an array for each field value we want to always grab
      # the first element of the array for id, even if it is nil
      id                  = [params["#{resource}[id]"]].flatten.first
      body                = is_unique?(resource, attribute, value, id).to_s
      [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, body]
    else
      @app.call(env)
    end
  end
  
  private
  
  def get_validations(resource)
    constantize_resource(resource).new.validations_to_json
  end
  
  def is_unique?(resource, attribute, value, id = nil)
    klass    = constantize_resource(resource)
    instance = nil
    instance = klass.send("find_by_#{attribute}", value)
    
    if instance
      return instance.id.to_i == id.to_i
    else
      return true
    end
  end
  
  def constantize_resource(resource)
    eval(resource.split('_').map{ |word| word.capitalize}.join)
  end
  
end

require 'client_side_validations/orm'
require 'client_side_validations/template'