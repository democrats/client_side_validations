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
                  validations.symbolize_keys!
                  unless options.key?(:html)
                    options[:html] = {}
                  end
                  
                  if validations[:url]
                    options[:html]['data-csv-url'] = validations[:url]
                  else
                    raise "No URL Given"
                  end
                  if validations[:adapter]
                    options[:html]['data-csv-adapter'] = validations[:adapter]
                  end
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