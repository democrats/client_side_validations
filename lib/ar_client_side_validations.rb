require 'rubygems'
unless defined?(ActiveRecord)
  unless require 'active_record'
    raise 'ActiveRecord Not Found'
  end
end
require 'validation_reflection'

module DNCLabs
  module ValidationsToJSON
    def validations_to_json(*attrs)
      hash = Hash.new { |h, attribute| h[attribute] = [] }
      attrs.each do |attr|
        hash[attr] << self.validation_to_hash(attr)
      end
      hash.to_json
    end
    
    def validation_to_hash(_attr, _options = {})
      validation_hash = {}
      self.class.reflect_on_validations_for(_attr).each do |validation|
        message = get_validation_message(validation, _options[:locale])
        validation.options.delete(:message)
        options = get_validation_options(validation.options)
        method  = get_validation_method(validation)
        if conditional_method = options['if']
          if self.instance_eval(conditional_method.to_s)
            options.delete('if')
            validation_hash[method] = { 'message' => message }.merge(options)
          end
        elsif conditional_method = options['unless']
          unless self.instance_eval(conditional_method.to_s)
            options.delete('unless')
            validation_hash[method] = { 'message' => message }.merge(options)
          end
        else
          validation_hash[method] = { 'message' => message }.merge(options)
        end
      end

      validation_hash
    end

    private

    def get_validation_message(validation, locale)
      default = case validation.macro.to_s
      when 'validates_presence_of'
        I18n.translate('activerecord.errors.messages.blank', :locale => locale)
      when 'validates_format_of'
        I18n.translate('activerecord.errors.messages.invalid', :locale => locale)
      when 'validates_length_of'
        if count = validation.options[:minimum]
          I18n.translate('activerecord.errors.messages.too_short', :locale => locale).sub('{{count}}', count.to_s)
        elsif count = validation.options[:maximum]
          I18n.translate('activerecord.errors.messages.too_long', :locale => locale).sub('{{count}}', count.to_s)
        end
      when 'validates_numericality_of'
        I18n.translate('activerecord.errors.messages.not_a_number', :locale => locale)
      end

      message = validation.options[:message]
      if message.kind_of?(String)
        message
      elsif message.kind_of?(Symbol)
        I18n.translate("activerecord.errors.models.#{self.class.to_s.downcase}.attributes.#{validation.name}.#{message}", :locale => locale)
      else
        default
      end
    end

    def get_validation_options(options)
      options = options.stringify_keys
      options.delete('on')
      if options['with'].kind_of?(Regexp)
        options['with'] = options['with'].inspect.to_s.sub("\\A","^").sub("\\Z","$").sub(%r{^/},"").sub(%r{/i?$}, "")
      end
      if options['minimum']
        options['value'] = options.delete('minimum')
      end
      if options['maximum']
        options['value'] = options.delete('maximum')
      end    
      options
    end

    def get_validation_method(validation)
      case validation.macro.to_s
      when 'validates_presence_of'
        'required'
      when 'validates_length_of'
        if validation.options[:minimum]
          'minlength'
        elsif validation.options[:maximum]
          'maxlength'
        end
      when 'validates_numericality_of'
        'digits'
      when 'validates_format_of'
        'format'
      else
        validation.macro.to_s
      end
    end
  end

end

ActiveRecord::Base.class_eval do
  include DNCLabs::ValidationsToJSON
end