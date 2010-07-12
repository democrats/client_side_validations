module DNCLabs
  module ClientSideValidations
    module Adapters
      class ORMBase
        attr_accessor :base
        
        def initialize(base)
          self.base = base
        end
        
        def validation_to_hash(attr)
        end
        
        def validation_fields
          []
        end
        
        private
        
        def build_validation_hash(validation, message_key = 'message')
          if can_validate?(validation) && supported_validation?(validation)
            validation_hash = {}
            message         = get_validation_message(validation)
            options         = get_validation_options(validation)
            method          = get_validation_method(validation)

            if validation.options.has_key?(:minimum) && validation.options.has_key?(:maximum)
              message_key       = 'message_min'
              cloned_validation = validation.clone
              cloned_validation.options.delete(:minimum)
              validation_hash.merge!(build_validation_hash(cloned_validation, 'message_max'))
            end
            
            new_validation_hash = { method => { message_key => message }.merge(options.stringify_keys) }
            
            unless validation_hash.empty?
              validation_hash["length"].merge!(new_validation_hash["length"])
              validation_hash
            else
              new_validation_hash
            end
          else
            {}
          end
        end
        
        def supported_validation?(validation)
          [:presence, :format, :length, :numericality, :uniqueness,
            :confirmation, :acceptance ].include?(validation.kind.to_sym)
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
        end

        def get_validation_options(validation)
          options = validation.options.clone
          options.symbolize_keys!
          deleteable_keys = [:on, :tokenizer, :only_integer, :allow_nil, :case_sensitive, :accept, :if, :unless]
          options.delete(:maximum) if options.has_key?(:minimum)
          options.delete_if { |k, v| deleteable_keys.include?(k) }
          if options[:with].kind_of?(Regexp)
            options[:with] = options[:with].inspect.to_s.sub("\\A","^").sub("\\Z","$").sub(%r{^/},"").sub(%r{/i?$}, "")
          end
          options
        end
        
        def get_validation_method(validation)
        end
        
      end
    end
  end
end