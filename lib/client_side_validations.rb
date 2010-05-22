require 'rubygems'

# if defined?(ActiveRecord)
#   if ActiveRecord::VERSION::MAJOR == 2
    require 'adapters/active_record_2'
#   end
# end

module DNCLabs
  module ClientSideValidations
    def validations_to_json(*attrs)
      hash = Hash.new { |h, attribute| h[attribute] = [] }
      attrs.each do |attr|
        hash[attr] << validation_to_hash(attr)
      end
      hash.to_json
    end
    
    def validation_to_hash(_attr, _options = {})
      @dnc_csv_adapter ||= DNCLabs::ClientSideValidations::Adapters::ActiveRecord2.new(self)
      @dnc_csv_adapter.validation_to_hash(_attr, _options)
    end
    
  end
end

ActiveRecord::Base.class_eval do
  include DNCLabs::ClientSideValidations
end