module DNCLabs
  module ClientSideValidations
    module Adapters
      module ActionView
        module BaseMethods
          
          def self.included(base)
            form_method = base.instance_method(:form_for)
            base.class_eval do
              define_method(:form_for) do |record_or_name_or_array, *args, &proc|
                options = args.extract_options!
                options.symbolize_keys!
                if validations = options.delete(:validations)
                  unless options.key?(:html)
                    options[:html] = {}
                  end
                  
                  unless validations == true
                    object = validations.to_s.underscore
                    rules  = validations.new.validations_to_json
                  else
                    object, rules = csv_get_object_and_rules(record_or_name_or_array)
                  end
                  
                  options[:html]['object-csv'] = object
                end
                args << options
                result = form_method.bind(self).call(record_or_name_or_array, *args, &proc)
                if object && rules
                  script = %{<script type='text/javascript'>var #{object}_rules=#{rules}</script>}
                  # output_buffer should be nil in Rails 3...
                  if output_buffer.present?
                    concat(script)
                  else
                    result += script.html_safe
                  end
                end
                result
              end
            end
          end
          
          private
          
          def csv_get_object_and_rules(record_or_name_or_array)
            case record_or_name_or_array
            when String, Symbol
              object = record_or_name_or_array.to_s
              rules  = object.camelize.constantize.new.validations_to_json
            when Array
              object, rules = csv_get_object_and_rules(record_or_name_or_array.last)
            else
              object = record_or_name_or_array.class.to_s.underscore
              rules  = record_or_name_or_array.validations_to_json
            end
            
            [object, rules]
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