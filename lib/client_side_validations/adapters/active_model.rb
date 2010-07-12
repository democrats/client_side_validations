require 'client_side_validations/adapters/orm_base'

module DNCLabs
  module ClientSideValidations
    module Adapters
      class ActiveModel < ORMBase

        def validation_to_hash(attr)
          base._validators[attr.to_sym].inject({}) do |hash, validation|
            hash.merge!(build_validation_hash(validation.clone))
          end
        end
        
        def validation_fields
          base._validators.keys
        end
        
        private
        
        def get_validation_message(validation)
          default = case validation.kind
          when :presence
            I18n.translate('errors.messages.blank')
          when :format
            I18n.translate('errors.messages.invalid')
          when :length
            if count = validation.options[:minimum]
              I18n.translate('errors.messages.too_short').sub('%{count}', count.to_s)
            elsif count = validation.options[:maximum]
              I18n.translate('errors.messages.too_long').sub('%{count}', count.to_s)
            end
          when :numericality
            I18n.translate('errors.messages.not_a_number')
          when :uniqueness
            if defined?(ActiveRecord) && base.kind_of?(ActiveRecord::Base)
              I18n.translate('activerecord.errors.messages.taken')
            elsif defined?(Mongoid) && base.class.included_modules.include?(Mongoid::Document)
              I18n.translate('errors.messages.taken')
            end
          when :confirmation
            I18n.translate('errors.messages.confirmation')
          when :acceptance
            I18n.translate('errors.messages.accepted')
          end

          message = validation.options.delete(:message)
          if message.kind_of?(String)
            message
          elsif message.kind_of?(Symbol)
            I18n.translate("errors.models.#{base.class.to_s.downcase}.attributes.#{validation.attributes.first}.#{message}")
          else
            default
          end
        end

        def get_validation_method(validation)
          validation.kind.to_s
        end
        
      end
    end
  end
end