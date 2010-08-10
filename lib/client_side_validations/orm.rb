require 'client_side_validations/adapters/active_model'

module ClientSideValidations
  module ORM
    def validate_options
      ValidateOptions.new(self).to_hash
    end

    def validation_fields
      self._validators.keys
    end
    
    class ValidateOptions
      attr_accessor :base
      
      def initialize(base)
        self.base = base
      end
    
      def to_hash
        rules    = Hash.new { |h, field| h[field] = {} }
        messages = Hash.new { |h, field| h[field] = {} }
        base.validation_fields.each do |field|
          validations = validations_for(field)
          rules[field.to_s].merge!(extract_rules(validations, field))
          messages[field.to_s].merge!(extract_messages(validations))
        end
        {"rules" => rules, "messages" => messages}
      end

      def validations_for(field)
        adapter.validations_to_hash(field)
      end

      private

      def convert_kind(kind, options = nil)
        case kind
        when 'acceptance', 'exclusion', 'inclusion', 'format'
          kind
        when 'confirmation'
          'equalTo'
        when 'presence'
          'required'
        when 'numericality'
          if options['only_integer']
            'digits'
          elsif options['greater_than']
            'greater_than'
          elsif options['greater_than_or_equal_to']
            'min'
          elsif options['less_than']
            'less_than'
          elsif options['less_than_or_equal_to']
            'max'
          elsif options['odd']
            'odd'
          elsif options['even']
            'even'
          else
            'numericality'
          end
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
          when 'acceptance', 'required', 'digits', 'numericality', 'greater_than', 'min', 'less_than', 'max', 'odd', 'even'
            true
          when 'format'
            options['with']
          when 'equalTo'
            %{[name="#{field}_confirmation"]}
          when 'exclusion', 'inclusion'
            options['in']
          when 'islength'
            options['is']
          when 'minlength'
            options['minimum']
          when 'maxlength'
            options['maximum']
          when 'remote'
            if base.new_record?
              data = {}
            else
              data = { "#{base.class.to_s.underscore}[id]" => base.id}
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
    
          if numericality?(kind)
            unless rules['numericality'] || rules['digits']
              rules['numericality'] = true
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

          if numericality?(kind)
            messages['numericality'] = I18n.translate(i18n_prefix + 'errors.messages.not_a_number')
          end

          if required?(kind, options)
            unless messages['required']
              if ['greater_than', 'min', 'less_than', 'max', 'odd', 'even'].include?(kind)
                messages['required']     = I18n.translate(i18n_prefix + 'errors.messages.not_a_number')
              else
                messages['required'] = options['message']
              end
            end
          end
        end
        messages
      end

      def i18n_prefix
        if defined?(::ActiveModel)
          ''
        else # ActiveRecord 2.x
          'activerecord.'
        end
      end

      def numericality?(kind)
        ['greater_than', 'min', 'less_than', 'max', 'even', 'odd'].include?(kind)
      end

      def required?(kind, options)
        case kind
        when 'digits', 'exclusion', 'inclusion', 'islength', 'minlength', 'remote', 'numericality', 'greater_than', 'min', 'less_than', 'max', 'even', 'odd', 'format'
          !options['allow_blank']
        when Array
          required?('minlength', options) if kind.include?('minlength')
        end
      end

      def adapter
        unless @adapter
          @adapter = ClientSideValidations::Adapters::ActiveModel.new(base)
        end
        @adapter
      end
    end
  end
end

if defined?(::ActiveModel)
  klass = ::ActiveModel::Validations

elsif defined?(::ActiveRecord)
  if ::ActiveRecord::VERSION::MAJOR == 2
    require 'validation_reflection/active_model'
    klass = ::ActiveRecord::Base
    
    ActiveRecord::Base.class_eval do
      ::ActiveRecordExtensions::ValidationReflection.reflected_validations << :validates_size_of
      ::ActiveRecordExtensions::ValidationReflection.install(self)
    end
  end
end

if klass
  klass.class_eval do
    include ClientSideValidations::ORM
  end
end