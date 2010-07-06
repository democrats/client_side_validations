require 'rubygems' unless defined?(Gem)
require 'json'

class ClientSideValidations
  def initialize(app)
    @app    = app
  end
  
  def call(env)
    case env['PATH_INFO']
    when %r{/(\w+)/validations.json}
      resource = $1
      body = get_validations(resource)
      [200, {'Content-Type' => 'application/json', 'Content-Length' => "#{body.length}"}, body]
    when %r{/(\w+)/validations/uniqueness/(\w+)}
      resource  = $1
      attribute = $2
      value     = env['QUERY_STRING'].split('=').last
      body = {"unique" => is_unique?(resource, attribute, value) }.to_json
      
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

module DNCLabs
  module ClientSideValidations
    def validations_to_json(*attrs)
      hash = Hash.new { |h, attribute| h[attribute] = {} }
      attrs.each do |attr|
        hash[attr].merge!(validation_to_hash(attr))
      end
      hash.to_json
    end
    
    def validation_to_hash(_attr, _options = {})
      @dnc_csv_adapter ||= Adapter.new(self)
      @dnc_csv_adapter.validation_to_hash(_attr, _options)
    end
  end
end

# ORM
if defined?(ActiveModel)
  require 'adapters/active_model'
  unless Object.respond_to?(:to_json)
    require 'active_support/json/encoding'
  end
  DNCLabs::ClientSideValidations::Adapter = DNCLabs::ClientSideValidations::Adapters::ActiveModel
  klass = ActiveModel::Validations
elsif defined?(ActiveRecord)
  if ActiveRecord::VERSION::MAJOR == 2
    require 'adapters/active_record_2'
    DNCLabs::ClientSideValidations::Adapter = DNCLabs::ClientSideValidations::Adapters::ActiveRecord2
    klass = ActiveRecord::Base
  end
end

if klass
  klass.class_eval do
    include DNCLabs::ClientSideValidations
  end
end

# Template
if defined?(ActionView)
  require 'adapters/action_view'
end