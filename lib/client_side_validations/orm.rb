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

if defined?(ActiveModel)
  require 'client_side_validations/adapters/active_model'
  DNCLabs::ClientSideValidations::Adapter = DNCLabs::ClientSideValidations::Adapters::ActiveModel
  klass = ActiveModel::Validations

elsif defined?(ActiveRecord)
  if ActiveRecord::VERSION::MAJOR == 2
    require 'client_side_validations/adapters/active_record_2'
    DNCLabs::ClientSideValidations::Adapter = DNCLabs::ClientSideValidations::Adapters::ActiveRecord2
    klass = ActiveRecord::Base
  end
end

if klass
  klass.class_eval do
    include DNCLabs::ClientSideValidations
  end
end
