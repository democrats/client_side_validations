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
                script = ""
                if validations = options.delete(:validations)
                  unless options.key?(:html)
                    options[:html] = {}
                  end
                  object, rules, csv_options = csv_get_variables(validations, record_or_name_or_array)
                  options[:html]['object-csv'] = object
                  csv_rules = %{var #{object}_validation_rules=#{rules};}
                  script    = %{<script type='text/javascript'>#{csv_rules}#{csv_options}</script>}
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
            version=
              if defined?(ActionPack::VERSION::MAJOR)
                ActionPack::VERSION::MAJOR
              end
            !version.blank? && version >= 3
          end
          
          def csv_get_variables(validations, record_or_name_or_array)
            csv_options = ::ClientSideValidations.default_options || { }
            case validations
            when true
              object, rules = csv_get_object_and_validation_rules(record_or_name_or_array)
            when Hash
              validations.symbolize_keys!
              if validations.has_key?(:instance)
                object = validations[:instance].class.to_s.underscore
                rules  = validations[:instance].validations_to_json
              elsif validations.has_key?(:class)
                object = validations[:instance].to_s.underscore
                rules  = validations[:instance].new.validations_to_json
              else
                object, rules = csv_get_object_and_validation_rules(record_or_name_or_array)
              end
              if validations.has_key?(:options)
                csv_options.merge!(validations[:options])
              end
            else
              object = validations.to_s.underscore
              rules  = validations.new.validations_to_json
            end
            
            if csv_options.empty?
              csv_options = ""
            else
              csv_options = %{var #{object}_validation_options=#{convert_csv_options_to_json(csv_options)};}
            end
            
            [object, rules, csv_options]
          end
          
          def convert_csv_options_to_json(csv_options)
            json = []
            csv_options.each do |k, v|
              json << %{#{k}:#{v}}
            end
            %{{#{json.join(',')}}}
          end
          
          def csv_get_object_and_validation_rules(record_or_name_or_array)
            case record_or_name_or_array
            when String, Symbol
              object = record_or_name_or_array.to_s
              rules  = object.camelize.constantize.new.validations_to_json
            when Array
              object, rules = csv_get_object_and_validation_rules(record_or_name_or_array.last)
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