require 'rubygems'
require 'json'
require 'cgi'

module ClientSideValidations
  def self.default_options=(options)
    @default_options = options
  end
  
  def self.default_options
    @default_options
  end
  
  class Uniqueness
    def initialize(app)
      @app = app
    end
  
    def call(env)
      # By default CGI::parse will instantize a hash that defaults nil elements to [].
      # We need to override this
      case env['PATH_INFO']
      when %r{^/validations/uniqueness.json}
        params              = {}.merge!(CGI::parse(env['QUERY_STRING']))
        field               = params.keys.first
        resource, attribute = field.split(/[^\w]/)
        value               = params[field][0]
        # Because params returns an array for each field value we want to always grab
        # the first element of the array for id, even if it is nil
        id                  = [params["#{resource}[id]"]].flatten.first
        body                = is_unique?(resource, attribute, value, id).to_s
        [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, [body]]
      else
        @app.call(env)
      end
    end
  
    private
  
    def is_unique?(resource, attribute, value, id = nil)
      klass    = constantize_resource(resource)
      instance = nil
      instance = klass.send("find_by_#{attribute}", value)
    
      if instance
        if defined?(ActiveRecord) && instance.kind_of?(ActiveRecord::Base)
          return instance.id.to_i == id.to_i
        elsif defined?(Mongoid) && instance.class.included_modules.include?(Mongoid::Document)
          return instance.id.to_s == id.to_s
        end
      else
        return true
      end
    end
  
    def constantize_resource(resource)
      eval(resource.split('_').map{ |word| word.capitalize}.join)
    end
  end
end

require 'client_side_validations/orm'
require 'client_side_validations/template'
require 'client_side_validations/rails' if defined?(Rails)