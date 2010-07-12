require 'validation_reflection'
require 'client_side_validations/adapters/orm_base'

module DNCLabs
  module ClientSideValidations
    module Adapters
      class ActiveRecord2 < ORMBase

        def validation_to_hash(attr)
          base.class.reflect_on_validations_for(attr).inject({}) do |hash, validation|
            hash.merge!(build_validation_hash(validation.clone))
          end
        end
        
        def build_validation_hash(validation, message_key = 'message')
          if range = validation.options.delete(:within)
            validation.options[:minimum] = range.first
            validation.options[:maximum] = range.last
          end
          super
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
          elsif if_condition = validation.options[:if]
            base.instance_eval(if_condition.to_s)
          elsif unless_condition = validation.options[:unless]
            !base.instance_eval(unless_condition.to_s)
          else
            true
          end
        end

        def get_validation_message(validation)
          default = case validation.macro.to_sym
          when :validates_presence_of
            I18n.translate('activerecord.errors.messages.blank')
          when :validates_format_of
            I18n.translate('activerecord.errors.messages.invalid')
          when :validates_length_of
            if count = validation.options[:minimum]
              I18n.translate('activerecord.errors.messages.too_short').sub('{{count}}', count.to_s)
            elsif count = validation.options[:maximum]
              I18n.translate('activerecord.errors.messages.too_long').sub('{{count}}', count.to_s)
            end
          when :validates_numericality_of
            I18n.translate('activerecord.errors.messages.not_a_number')
          when :validates_uniqueness_of
            I18n.translate('activerecord.errors.messages.taken')
          when :validates_confirmation_of
            I18n.translate('activerecord.errors.messages.confirmation')
          when :validates_acceptance_of
            I18n.translate('activerecord.errors.messages.accepted')
          end
          
          message = validation.options.delete(:message)
          if message.kind_of?(String)
            message
          elsif message.kind_of?(Symbol)
            I18n.translate("activerecord.errors.models.#{base.class.to_s.downcase}.attributes.#{validation.name}.#{message}")
          else
            default
          end
        end

        def get_validation_method(validation)
          method = case validation.macro.to_sym
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