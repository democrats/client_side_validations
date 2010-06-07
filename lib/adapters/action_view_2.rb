module DNCLabs
  module ClientSideValidations
    module Adapters
      module ActionView2
        module BaseMethods
  
          def client_side_validations(object_name, options = {})
            url     = options.delete(:url)
            raise "No URL Specified!" unless url
            adapter = options.delete(:adapter) || 'jquery.validate'
    <<-JS
      <script type="text/javascript">
        $(document).ready(function() {
          $('##{dom_id(options[:object])}').clientSideValidations('#{url}', '#{adapter}');
        })
      </script>
    JS
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
  include DNCLabs::ClientSideValidations::Adapters::ActionView2::BaseMethods
end

ActionView::Helpers::FormBuilder.class_eval do
  include DNCLabs::ClientSideValidations::Adapters::ActionView2::FormBuilderMethods
end