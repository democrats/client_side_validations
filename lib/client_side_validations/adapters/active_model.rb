require 'client_side_validations/adapters/orm_base'

module ClientSideValidations
  module Adapters
    class ActiveModel < ORMBase

      def validations_to_hash(attr)
        base._validators[attr.to_sym].inject({}) do |hash, validation|
          hash.merge!(build_validation_hash(validation.clone))
        end
      end
      
      private

      def build_validation_hash(validation, message_key = 'message')
        if validation.kind == :inclusion || validation.kind == :exclusion
          validation.options[:in] = validation.options[:in].to_a
        end
        
        if validation.kind == :size
          validation.kind = :length
        end
        
        if validation.kind == :length &&
          (range = (validation.options.delete(:within) || validation.options.delete(:in)))
          validation.options[:minimum] = range.first
          validation.options[:maximum] = range.last
        elsif validation.kind == :inclusion || validation.kind == :exclusion
          validation.options[:in] = validation.options[:in].to_a
        end
        
        super
      end

      def supported_validation?(validation)
        SupportedValidations.include?(validation.kind.to_sym)
      end
      
      def get_validation_message(validation)
        default = case validation.kind
        when :presence
          I18n.translate(i18n_prefix + 'errors.messages.blank')
        when :format
          I18n.translate(i18n_prefix + 'errors.messages.invalid')
        when :length
          if count = validation.options[:is]
            I18n.translate(i18n_prefix + 'errors.messages.wrong_length').sub(orm_error_interpolation(:count), count.to_s)
          elsif count = validation.options[:minimum]
            I18n.translate(i18n_prefix + 'errors.messages.too_short').sub(orm_error_interpolation(:count), count.to_s)
          elsif count = validation.options[:maximum]
            I18n.translate(i18n_prefix + 'errors.messages.too_long').sub(orm_error_interpolation(:count), count.to_s)
          end
        when :numericality
          if validation.options[:only_integer]
            I18n.translate(i18n_prefix + 'errors.messages.not_a_number')
          elsif count = validation.options[:greater_than]
            I18n.translate(i18n_prefix + 'errors.messages.greater_than').sub(orm_error_interpolation(:count), count.to_s)
          elsif count = validation.options[:greater_than_or_equal_to]
            I18n.translate(i18n_prefix + 'errors.messages.greater_than_or_equal_to').sub(orm_error_interpolation(:count), count.to_s)
          elsif count = validation.options[:less_than]
            I18n.translate(i18n_prefix + 'errors.messages.less_than').sub(orm_error_interpolation(:count), count.to_s)
          elsif count = validation.options[:less_than_or_equal_to]
            I18n.translate(i18n_prefix + 'errors.messages.less_than_or_equal_to').sub(orm_error_interpolation(:count), count.to_s)
          elsif validation.options[:odd]
            I18n.translate(i18n_prefix + 'errors.messages.odd')
          elsif validation.options[:even]
            I18n.translate(i18n_prefix + 'errors.messages.even')
          else
            I18n.translate(i18n_prefix + 'errors.messages.not_a_number')
          end
        when :uniqueness
          if defined?(ActiveRecord) && base.kind_of?(ActiveRecord::Base)
            I18n.translate('activerecord.errors.messages.taken')
          elsif defined?(Mongoid) && base.class.included_modules.include?(Mongoid::Document)
            I18n.translate('errors.messages.taken')
          end
        when :confirmation
          I18n.translate(i18n_prefix + 'errors.messages.confirmation')
        when :acceptance
          I18n.translate(i18n_prefix + 'errors.messages.accepted')
        when :inclusion
          I18n.translate(i18n_prefix + 'errors.messages.inclusion')
        when :exclusion
          I18n.translate(i18n_prefix + 'errors.messages.exclusion')
        end

        message = validation.options.delete(:message)
        if message.kind_of?(String)
          message
        elsif message.kind_of?(Symbol)
          I18n.translate(i18n_prefix + "errors.models.#{base.class.to_s.downcase}.attributes.#{validation.attributes.first}.#{message}")
        else
          default
        end
      end

      def get_validation_method(validation)
        validation.kind.to_s
      end
      
      def i18n_prefix
        if defined?(::ActiveModel)
          ''
        else # ActiveRecord 2.x
          'activerecord.'
        end
      end
      
      def orm_error_interpolation(name)
        if defined?(::ActiveModel)
          "%{#{name}}"
          
        else # ActiveRecord 2.x
          "{{#{name}}}"
        end
      end
      
    end
  end
end