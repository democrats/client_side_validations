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
                  else
                    case record_or_name_or_array
                    when String, Symbol
                      object = record_or_name_or_array.to_s
                    else
                      object = record_or_name_or_array.class.to_s.underscore
                    end
                  end
                  
                  options[:html]['object-csv'] = object
                end
                args << options
                form_method.bind(self).call(record_or_name_or_array, *args, &proc)
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