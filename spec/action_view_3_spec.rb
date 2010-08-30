require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'actionpack', '~> 3.0'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'client_side_validations'

describe 'ActionView 3.x Form Helper' do
  let(:charset) { %{accept-charset="UTF-8" } }
  
  context 'ActionView::Base' do
    before do
      class Book; end
      Book.any_instance.stubs(:validate_options).returns({"messages" => {}, "rules" => {}})
    end

    subject do
      view = ActionView::Base.new
      view.stubs(:protect_against_forgery?).returns(false)
      view
    end
    
    context 'name' do
      let(:object)      { 'book' }
      let(:object_name) { object }
      let(:attributes)  { %{data-csv="#{object_name}" } }
      let(:content)     { %{<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>} }
      it_should_behave_like 'extended form_for'
    end
    
    context 'record' do
      before do
        model_name = 'Book'
        model_name.stubs(:singular).returns('book')
        Book.stubs(:model_name).returns(model_name)
        @book = Book.new
        @id   = 1
      end
      
      context 'new' do
        before do
          @book.stubs(:to_key).returns(nil)
        end
        let(:object)      { @book }
        let(:object_name) { 'new_book' }
        let(:attributes)  { %{class="new_book" data-csv="#{object_name}" id="#{object_name}" } }
        let(:content)     { %{<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>} }
        it_should_behave_like 'extended form_for'
      end
      
      context 'existing' do
        before do
          @book.stubs(:to_key).returns([@id])
          @book.stubs(:id).returns(@id)
          @book.stubs(:persisted?).returns(true)
        end
        let(:object)      { @book }
        let(:object_name) { 'book_1'}
        let(:attributes)  { %{class="edit_book" data-csv="#{object_name}" id="edit_#{object_name}" } }
        let(:content)     { %{<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="_method" type="hidden" value="put" /></div>} }
        it_should_behave_like 'extended form_for'
      end

      context 'array' do
        before do
          @book.stubs(:to_key).returns(nil)
        end
        let(:object)      { [@book] }
        let(:object_name) { 'new_book' }
        let(:attributes)  { %{class="new_book" data-csv="#{object_name}" id="#{object_name}" } }
        let(:content)     { %{<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>} }
        it_should_behave_like 'extended form_for'
      end
    end
    
    context 'With validate options' do
      context 'on a name' do
        before do
          Book.any_instance.stubs(:validate_options).returns({'rules' => {'name' => {'required' => true}}, 'messages' => {'name' => {'required' => 'Must be present'}}})
          @validate_options = %'{"messages":{"book[name]":{"required":"Must be present"}},"rules":{"book[name]":{"required":true}}}'
        end
        let(:object)      { 'book' }
        let(:object_name) { object }
        let(:attributes)  { %{data-csv="#{object_name}" } }
        let(:content)     { %{<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>} }
        it_should_behave_like 'extended form_for'
      end

      context 'new record' do
        before do
          Book.any_instance.stubs(:validate_options).returns({'rules' => {'name' => {'required' => true}}, 'messages' => {'name' => {'required' => 'Must be present'}}})
          @validate_options = %'{"messages":{"book[name]":{"required":"Must be present"}},"rules":{"book[name]":{"required":true}}}'

          model_name = 'Book'
          model_name.stubs(:singular).returns('book')
          Book.stubs(:model_name).returns(model_name)
          @book = Book.new
          @id   = 1
          @book.stubs(:to_key).returns(nil)
        end
        let(:object)      { 'book' }
        let(:object_name) { object }
        let(:attributes)  { %{data-csv="#{object_name}" } }
        let(:content)     { %{<div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>} }
        it_should_behave_like 'extended form_for'
      end
    end

  end
end