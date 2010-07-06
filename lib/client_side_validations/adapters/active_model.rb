module DNCLabs
  module ClientSideValidations
    module Adapters
      class ActiveModel
        attr_accessor :base
        
        def initialize(base)
          self.base = base
        end
        
        def validation_to_hash(_attr, _options = {})
          validation_hash = {}
          base._validators[_attr.to_sym].each do |validation|
            message = get_validation_message(validation, _options[:locale])
            validation.options.delete(:message)
            options = get_validation_options(validation.options)
            method  = get_validation_method(validation.kind)
            if conditional_method = remove_reserved_conditionals(options['if'])
              if base.instance_eval(conditional_method.to_s)
                options.delete('if')
                validation_hash[method] = { 'message' => message }.merge(options)
              end
            elsif conditional_method = options['unless']
              unless base.instance_eval(conditional_method.to_s)
                options.delete('unless')
                validation_hash[method] = { 'message' => message }.merge(options)
              end
            else
              options.delete('if')
              options.delete('unless')
              validation_hash[method] = { 'message' => message }.merge(options)
            end
          end

          validation_hash
        end
        
        private

        def get_validation_message(validation, locale)
          default = case validation.kind
          when :presence
            I18n.translate('errors.messages.blank', :locale => locale)
          when :format
            I18n.translate('errors.messages.invalid', :locale => locale)
          when :length
            if count = validation.options[:minimum]
              I18n.translate('errors.messages.too_short', :locale => locale).sub('%{count}', count.to_s)
            elsif count = validation.options[:maximum]
              I18n.translate('errors.messages.too_long', :locale => locale).sub('%{count}', count.to_s)
            end
          when :numericality
            I18n.translate('errors.messages.not_a_number', :locale => locale)
          end

          message = validation.options[:message]
          if message.kind_of?(String)
            message
          elsif message.kind_of?(Symbol)
            I18n.translate("errors.models.#{base.class.to_s.downcase}.attributes.#{validation.attributes.first}.#{message}", :locale => locale)
          else
            default
          end
        end

        def get_validation_options(options)
          options = options.stringify_keys
          if options.delete('on') == :create
            options.delete('if')
          end
          options.delete('tokenizer')
          options.delete('only_integer')
          options.delete('allow_nil')
          if options['with'].kind_of?(Regexp)
            options['with'] = options['with'].inspect.to_s.sub("\\A","^").sub("\\Z","$").sub(%r{^/},"").sub(%r{/i?$}, "")
          end
          options
        end
        
        def get_validation_method(kind)
          kind.to_s
        end
        
        def remove_reserved_conditionals(*conditionals)
          conditionals.flatten!
          conditionals.delete_if { |conditional| conditional =~ /@_/ }
          conditionals.first
        end
      end
    end
  end
end