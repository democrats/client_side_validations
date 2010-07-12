module DNCLabs
  module ClientSideValidations
    def validations_to_json
      hash = Hash.new { |h, field| h[field] = {} }
      validation_fields.each do |field|
        hash[field].merge!(validation_to_hash(field))
      end
      hash.to_json
    end
    
    def validation_to_hash(field)
      dnc_csv_adapter.validation_to_hash(field)
    end
    
    def validation_fields
      dnc_csv_adapter.validation_fields
    end
    
    def dnc_csv_adapter
      unless @dnc_csv_adapter
        @dnc_csv_adapter = Adapter.new(self)
      end
      @dnc_csv_adapter
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