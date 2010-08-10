module DNCLabs
  module ClientSideValidations
    module Adapters
      module ActionView
        module BaseMethods
          
          def self.included(base)
            form_method = base.instance_method(:form_for)
            base.class_eval do
              attr_accessor :validate_options
              
              define_method(:form_for) do |record_or_name_or_array, *args, &proc|
                options = Hash.new { |h, k| h[k] = {}}
                options.merge!(args.extract_options!.symbolize_keys!)
                script = ""
                if validations = options.delete(:validations)
                  set_validate_options(validations, record_or_name_or_array)
                  options[:html]['data-csv'] = validate_options.delete('data-csv')
                  script = %{<script type='text/javascript'>var #{options[:html]['data-csv']}_validate_options=#{validate_options.to_json};</script>}
                end
                args << {}.merge(options)
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
          
          def set_validate_options(validations, record_or_name_or_array)
            options = ::ClientSideValidations.default_options || { }
            
            case validations
            when true
              object_name      = get_object_name(record_or_name_or_array)
              data_csv         = get_data_csv(record_or_name_or_array)
              validate_options = rules_and_messages(record_or_name_or_array)
            when Hash
              validations.symbolize_keys!
              if validations.has_key?(:instance)
                object_name      = get_object_name(validations[:instance])
                data_csv         = get_data_csv(validations[:instance])
                validate_options = validations[:instance].validate_options
              elsif validations.has_key?(:class)
                object_name      = get_object_name(validations[:class].new)
                data_csv         = get_data_csv(validations[:instance].new)
                validate_options = validations[:class].new.validate_options
              else
                object_name      = get_object_name(record_or_name_or_array)
                data_csv         = get_data_csv(record_or_name_or_array)
                validate_options = rules_and_messages(record_or_name_or_array)
              end

              options.merge!(validations[:options] || {})
            else
              object_name      = get_object_name(validations)
              data_csv         = get_data_csv(validations)
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
          
          def convert_options_to_json(options)
            json = []
            options.each do |k, v|
              json << %{#{k}:#{v}}
            end
            %{{#{json.join(',')}}}
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
          
          def get_data_csv(object)
            case object
            when String, Symbol
              object.to_s
            when Array
              get_data_csv(object.last)
            when Class
              object.to_s.underscore
            else
              dom_id(object)
            end
          end
          
          def get_object_name(object)
            case object
            when String, Symbol
              object.to_s
            when Array
              get_object_name(object.last)
            when Class
              get_object_name(object.new)
            else
              if rails3?
                ActiveModel::Naming.singular(object)
              else
                ActionController::RecordIdentifier.singular_class_name(object)
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
end

ActionView::Base.class_eval do
  include DNCLabs::ClientSideValidations::Adapters::ActionView::BaseMethods
end

ActionView::Helpers::FormBuilder.class_eval do
  include DNCLabs::ClientSideValidations::Adapters::ActionView::FormBuilderMethods
end