module ClientSideValidations
  module Adapters
    module ActionView
      module BaseMethods
        
        def self.included(base)
          form_method = base.instance_method(:form_for)
          base.class_eval do
            attr_accessor :validate_options
            
            define_method(:form_for) do |record_or_name_or_array, *args, &proc|
              options = args.extract_options!.symbolize_keys!
              script = ""
              if validations = options.delete(:validations)
                set_validate_options(validations, record_or_name_or_array, options)
                unless options.has_key?(:html)
                  options[:html] = {}
                end
                options[:html]['data-csv'] = validate_options.delete('data-csv')
                script = %{<script type='text/javascript'>var #{options[:html]['data-csv']}_validate_options=#{validate_options.to_json};</script>}
              end
              args << options
              result = form_method.bind(self).call(record_or_name_or_array, *args, &proc)
              if rails3?
                result += script.html_safe
              else
                concat(script)
              end
              result
            end
          end
        end
        
        private
        
        def rails3?
          version =
            if defined?(ActionPack::VERSION::MAJOR)
              ActionPack::VERSION::MAJOR
            end
          !version.blank? && version >= 3
        end
        
        def set_validate_options(validations, record_or_name_or_array, form_for_options)
          options = ::ClientSideValidations.default_options || { }
          
          case validations
          when true
            object_name      = get_object_name(record_or_name_or_array, form_for_options)
            data_csv         = get_data_csv(record_or_name_or_array, form_for_options)
            validate_options = rules_and_messages(record_or_name_or_array)
          when Hash
            validations.symbolize_keys!
            if validations.has_key?(:instance)
              object_name      = get_object_name(validations[:instance], form_for_options)
              data_csv         = get_data_csv(validations[:instance], form_for_options)
              validate_options = validations[:instance].validate_options
            elsif validations.has_key?(:class)
              object_name      = get_object_name(validations[:class], form_for_options)
              data_csv         = get_data_csv(validations[:class], form_for_options)
              validate_options = validations[:class].new.validate_options
            else
              object_name      = get_object_name(record_or_name_or_array, form_for_options)
              data_csv         = get_data_csv(record_or_name_or_array, form_for_options)
              validate_options = rules_and_messages(record_or_name_or_array)
            end

            options.merge!(validations[:options] || {})
          else
            object_name      = get_object_name(validations, form_for_options)
            data_csv         = get_data_csv(validations, form_for_options)
            validate_options = validations.new.validate_options
          end
          
          self.validate_options = build_validate_options(object_name, validate_options, options, data_csv)
        end
        
        def build_validate_options(object_name, validate_options, options, data_csv)
          %w{rules messages}.each do |option|
            validate_options[option].keys.each do |key|
              validate_options[option]["#{object_name}[#{key}]"] = validate_options[option].delete(key)
            end
          end
          
          validate_options['options']  = options unless options.empty?
          validate_options['data-csv'] = data_csv
          validate_options
        end
        
        def rules_and_messages(record_or_name_or_array)
          case record_or_name_or_array
          when String, Symbol
            record_or_name_or_array.to_s.camelize.constantize.new.validate_options
          when Array
            rules_and_messages(record_or_name_or_array.last)
          else
            record_or_name_or_array.validate_options
          end
        end
        
        def get_data_csv(object, form_for_options)
          case object
          when String, Symbol
            form_for_options[:as] || object.to_s
          when Array
            get_data_csv(object.last, form_for_options)
          when Class
            form_for_options[:as] || object.to_s.underscore
          else
            if object.respond_to?(:persisted?) && object.persisted?
              form_for_options[:as] ? "#{form_for_options[:as]}_edit" : dom_id(object)
            else
              form_for_options[:as] ? "#{form_for_options[:as]}_new" : dom_id(object)
            end
          end
        end
        
        def get_object_name(object, form_for_options)
          case object
          when String, Symbol
            form_for_options[:as] || object.to_s
          when Array
            get_object_name(object.last, form_for_options)
          when Class
            get_object_name(object.new, form_for_options)
          else
            if rails3?
              form_for_options[:as] || ::ActiveModel::Naming.singular(object)
            else
              form_for_options[:as] || ::ActionController::RecordIdentifier.singular_class_name(object)
            end
          end
        end
      end # BaseMethods
      
      module FormBuilderMethods
      
        def client_side_validations(options = {})
          @template.send(:client_side_validations, @object_name, objectify_options(options))
        end
        
      end # FormBuilderMethods
    end
  end
end

ActionView::Base.class_eval do
  include ClientSideValidations::Adapters::ActionView::BaseMethods
end

ActionView::Helpers::FormBuilder.class_eval do
  include ClientSideValidations::Adapters::ActionView::FormBuilderMethods
end