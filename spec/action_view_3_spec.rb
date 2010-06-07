require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'actionpack', '~> 3.0'
require 'action_pack'
require 'action_view'
require 'client_side_validations'

describe 'ActionView 2.x Form Helper' do
  context 'ActionView::Base' do
    subject { ActionView::Base.new }
    
    context 'only the url' do
      before do
        @object_name = 'object'
        @url         = '/objects/new.json'
        @expected_javascript = <<-JS
      <script type="text/javascript">
        $(document).ready(function() {
          $('##{@object_name}').clientSideValidations('#{@url}', 'jquery.validate');
        })
      </script>
    JS
        subject.should_receive(:dom_id).and_return(@object_name)
      end
      
      it 'should generate the proper javascript' do
        subject.client_side_validations(@object_name, 
          :url => @url).should == @expected_javascript
      end
    end
    
    context 'a different adapter' do
      before do
        @object_name = 'object'
        @url         = '/objects/new.json'
        @adapter     = 'some.other.adapter'
        @expected_javascript = <<-JS
      <script type="text/javascript">
        $(document).ready(function() {
          $('##{@object_name}').clientSideValidations('#{@url}', '#{@adapter}');
        })
      </script>
    JS
        subject.should_receive(:dom_id).and_return(@object_name)
      end
      
      it 'should generate the proper javascript' do
        subject.client_side_validations(@object_name, 
          :url => @url, :adapter => @adapter).should == @expected_javascript
      end
    end

    context 'not including the :url' do
      before do
        @object_name = 'object'
        @adapter     = 'some.other.adapter'
        @expected_javascript = <<-JS
      <script type="text/javascript">
        $(document).ready(function() {
          $('##{@object_name}').clientSideValidations('#{@url}', '#{@some_other_adapter}');
        })
      </script>
    JS
      end
      
      it 'should raise an error' do
        expect {
          subject.client_side_validations(@object_name, 
            :adapter => @some_other_adapter)
        }.to raise_error
      end
    end
    
  end
end