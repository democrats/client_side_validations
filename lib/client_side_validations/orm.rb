module DNCLabs
  module ClientSideValidations
    def validate_options
      rules    = Hash.new { |h, field| h[field] = {} }
      messages = Hash.new { |h, field| h[field] = {} }
      validation_fields.each do |field|
        validations = validations_to_hash(field)
        rules[field.to_s].merge!(extract_rules(validations, field))
        messages[field.to_s].merge!(extract_messages(validations))
      end
      {"rules" => rules, "messages" => messages}
    end
    
    def validations_to_hash(field)
      dnc_csv_adapter.validations_to_hash(field)
    end
    
    private
    
    def convert_kind(kind, options = nil)
      case kind
      when 'acceptance', 'exclusion', 'inclusion'
        kind
      when 'confirmation'
        'equalTo'
      when 'presence'
        'required'
      when 'numericality'
        'digits'
      when 'length'
        if options['is']
          'islength'
        elsif options['minimum'] && options['maximum']
          ['minlength', 'maxlength']
        elsif options['minimum']
          'minlength'
        elsif options['maximum']
          'maxlength'
        end
      when 'uniqueness'
        'remote'
      end
    end
    
    def extract_rules(validations, field = nil)
      rules = {}
      validations.each do |kind, options|
        kind = convert_kind(kind, options)
        value = case kind
        when 'acceptance'
          true
        when 'equalTo'
          %{[name="#{field}_confirmation"]}
        when 'required'
          true
        when 'digits'
          true
        when 'exclusion', 'inclusion'
          options['in']
        when 'islength'
          options['is']
        when 'minlength'
          options['minimum']
        when 'maxlength'
          options['maximum']
        when 'remote'
          if self.new_record?
            data = {}
          else
            data = { "#{self.class.to_s.underscore}[id]" => self.id}
          end
          {'url' => '/validations/uniqueness.json', 'data' => data}
        end

        unless Array === kind
          rules[kind] = value
        else
          kind.each do |k|
            special_rule = case k
            when 'minlength'
              options['minimum']
            when 'maxlength'
              options['maximum']
            end
            
            rules[k] = special_rule
          end
        end

        if required?(kind, options)
          unless rules['required']
            rules['required'] = true
          end
        end
        
      end
      rules
    end
    
    def extract_messages(validations)
      messages = {}
      validations.each do |kind, options|
        kind = convert_kind(kind, options)
        unless Array === kind
          messages[kind] = options['message']
        else
          kind.each do |k|
            special_message = case k
            when 'minlength'
              options['message'] = options['message_min']
              'message_min'
            when 'maxlength'
              'message_max'
            end

            messages[k] = options[special_message]
          end
        end

        if required?(kind, options)
          unless messages['required']
            messages['required'] = options['message']
          end
        end
      end
      messages
    end
    
    def required?(kind, options)
      case kind
      when 'digits', 'exclusion', 'inclusion', 'islength', 'minlength', 'remote'
        !options['allow_blank']
      when Array
        required?('minlength', options) if kind.include?('minlength')
      end
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

if defined?(::ActiveModel)
  require 'client_side_validations/adapters/active_model'
  DNCLabs::ClientSideValidations::Adapter = DNCLabs::ClientSideValidations::Adapters::ActiveModel
  klass = ::ActiveModel::Validations

elsif defined?(::ActiveRecord)
  if ::ActiveRecord::VERSION::MAJOR == 2
    require 'validation_reflection/active_model'
    require 'client_side_validations/adapters/active_model'
    DNCLabs::ClientSideValidations::Adapter = DNCLabs::ClientSideValidations::Adapters::ActiveModel
    klass = ::ActiveRecord::Base
    
    ActiveRecord::Base.class_eval do
      ::ActiveRecordExtensions::ValidationReflection.reflected_validations << :validates_size_of
      ::ActiveRecordExtensions::ValidationReflection.install(self)
    end
  end
end

if klass
  klass.class_eval do
    include DNCLabs::ClientSideValidations
  end
end