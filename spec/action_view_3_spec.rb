require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'actionpack', '~> 3.0'
require 'action_pack'
require 'action_view'
require 'client_side_validations'

describe 'ActionView 3.x Form Helper' do
    context 'ActionView::Base' do
      subject { ActionView::Base.new }

      context 'only the url' do
        before do
          @object_name         = 'object'
          @url                 = '/objects/new.json'
          @expected_javascript = %{<script type="text/javascript">$(document).ready(function(){$('##{@object_name}').clientSideValidations('#{@url}','jquery.validate');});</script>}
          subject.should_receive(:dom_id).and_return(@object_name)
        end

        it 'should generate the proper javascript' do
          subject.client_side_validations(@object_name, 
            :url => @url).should == @expected_javascript
        end
      end

      context 'a different adapter' do
        before do
          @object_name         = 'object'
          @url                 = '/objects/new.json'
          @adapter             = 'some.other.adapter'
          @expected_javascript = %{<script type="text/javascript">$(document).ready(function(){$('##{@object_name}').clientSideValidations('#{@url}','#{@adapter}');});</script>}
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