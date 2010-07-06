require 'rubygems'
require 'json'

class ClientSideValidations
  def initialize(app)
    @app = app
  end
  
  def call(env)
    case env['PATH_INFO']
    when %r{/(\w+)/validations.json}
      resource = $1
      body     = get_validations(resource)
      [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, body]
      
    when %r{/(\w+)/validations/uniqueness/(\w+).json}
      resource  = $1
      attribute = $2
      value     = env['QUERY_STRING'].split('=').last
      body      = {"unique" => is_unique?(resource, attribute, value) }.to_json
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
    eval(resource.split('_').map{|word| word.capitalize}.join)
  end
end

require 'client_side_validations/orm'
require 'client_side_validations/template'