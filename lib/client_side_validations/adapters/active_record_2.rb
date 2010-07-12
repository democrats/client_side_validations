require 'validation_reflection'

module DNCLabs
  module ClientSideValidations
    module Adapters
      class ActiveRecord2
        attr_accessor :base
        
        def initialize(base)
          self.base = base
        end
        
        def validation_to_hash(attr, options = {})
          validation_hash = {}
          base.class.reflect_on_validations_for(attr).each do |validation|
            if can_validate?(validation) && supported_validation?(validation)
              message = get_validation_message(validation, options[:locale])
              validation.options.delete(:message)
              options = get_validationoptions(validation.options)
              method  = get_validation_method(validation.macro)
              if conditional_method = options[:if]
                if base.instance_eval(conditional_method.to_s)
                  options.delete(:if)
                  validation_hash[method] = { 'message' => message }.merge(options.stringify_keys)
                end
              elsif conditional_method = options[:unless]
                unless base.instance_eval(conditional_method.to_s)
                  options.delete(:unless)
                  validation_hash[method] = { 'message' => message }.merge(options.stringify_keys)
                end
              else
                validation_hash[method] = { 'message' => message }.merge(options.stringify_keys)
              end
            end
          end

          validation_hash
        end
        
        def validation_fields
          base.class.reflect_on_all_validations.map { |v| v.name }.uniq
        end
        
        private
        
        def supported_validation?(validation)
          [:validates_presence_of, :validates_format_of, :validates_length_of,
           :validates_numericality_of, :validates_uniqueness_of,
           :validates_confirmation_of, :validates_acceptance_of].include?(validation.macro.to_sym)
        end
        
        def can_validate?(validation)
          if on = validation.options[:on]
            on = on.to_sym
            (on == :save) ||
            (on == :create && base.new_record?) ||
            (on == :update && !base.new_record?)
          else
            true
          end
        end

        def get_validation_message(validation, locale)
          default = case validation.macro.to_sym
          when :validates_presence_of
            I18n.translate('activerecord.errors.messages.blank', :locale => locale)
          when :validates_format_of
            I18n.translate('activerecord.errors.messages.invalid', :locale => locale)
          when :validates_length_of
            if count = validation.options[:minimum]
              I18n.translate('activerecord.errors.messages.too_short', :locale => locale).sub('{{count}}', count.to_s)
            elsif count = validation.options[:maximum]
              I18n.translate('activerecord.errors.messages.too_long', :locale => locale).sub('{{count}}', count.to_s)
            end
          when :validates_numericality_of
            I18n.translate('activerecord.errors.messages.not_a_number', :locale => locale)
          when :validates_uniqueness_of
            I18n.translate('activerecord.errors.messages.taken', :locale => locale)
          when :validates_confirmation_of
            I18n.translate('activerecord.errors.messages.confirmation', :locale => locale)
          when :validates_acceptance_of
            I18n.translate('activerecord.errors.messages.accepted', :locale => locale)
          end

          message = validation.options[:message]
          if message.kind_of?(String)
            message
          elsif message.kind_of?(Symbol)
            I18n.translate("activerecord.errors.models.#{base.class.to_s.downcase}.attributes.#{validation.name}.#{message}", :locale => locale)
          else
            default
          end
        end

        def get_validationoptions(options)
          options.symbolize_keys!
          options.delete(:on)
          if options[:with].kind_of?(Regexp)
            options[:with] = options[:with].inspect.to_s.sub("\\A","^").sub("\\Z","$").sub(%r{^/},"").sub(%r{/i?$}, "")
          end
          options
        end
        
        def get_validation_method(method)
          method = case method.to_sym
          when :validates_presence_of
            :presence
          when :validates_format_of
            :format
          when :validates_numericality_of
            :numericality
          when :validates_length_of
            :length
          when :validates_uniqueness_of
            :uniqueness
          when :validates_confirmation_of
            :confirmation
          when :validates_acceptance_of
            :acceptance
          end
          
          method.to_s
        end
      end
    end
  end
end