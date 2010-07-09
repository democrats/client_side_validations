require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'actionpack', '~> 2.0'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'client_side_validations'

share_examples_for 'extended form_for' do
  let(:book_validation_rules) { %{<script type='text/javascript'>var book_validation_rules={}</script>} }
  context 'normal form_for options' do
    before do
      subject.form_for(book, :url => '/books') { }
      @result = subject.output_buffer
    end

    it 'should retain default behavior' do
      @result.should == %{<form action="/books" #{extra}method="post">#{content}</form>}
    end
  end

  context 'with validations' do
    before do
      subject.form_for(book, :url => '/books', :validations => true) { }
      @result = subject.output_buffer
    end

    it 'should generate the proper javascript' do
      @result.should == %{<form action="/books" #{extra}method="post" object-csv="book">#{content}</form>#{book_validation_rules}}
    end
  end

  context 'with validations overridden for a class' do
    before do
      class TestBook; end
      TestBook.any_instance.stubs(:validations_to_json).returns('{}')
      subject.form_for(book, :url => '/books', :validations => TestBook) { }
      @result = subject.output_buffer
    end
  
    it 'should generate the proper javascript' do
      @result.should == %{<form action="/books" #{extra}method="post" object-csv="test_book">#{content}</form><script type='text/javascript'>var test_book_validation_rules={}</script>}
    end
  end
end

describe 'ActionView 2.x Form Helper' do
  before do
    class Book; end
    Book.any_instance.stubs(:validations_to_json).returns('{}')
  end
  
  context 'ActionView::Base' do
    subject do
      view = ActionView::Base.new
      view.stubs(:protect_against_forgery?).returns(false)
      view.output_buffer = ActiveSupport::SafeBuffer.new
      controller = ActionController::Base.new
      view.stubs(:controller).returns(controller)
      view
    end
    
    context 'name' do
      let(:book)    { 'book' }
      let(:extra)   { nil }
      let(:content) { nil }
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
          @book.stubs(:new_record?).returns(true)
          @book.stubs(:id).returns(nil)
        end
        let(:book)    { @book }
        let(:extra)   { %{class="new_book" id="new_book" } }
        let(:content) { nil }
        it_should_behave_like 'extended form_for'
      end
      
      context 'existing' do
        before do
          @book.stubs(:to_key).returns([@id])
          @book.stubs(:id).returns(@id)
        end
        
        let(:book)    { @book }
        let(:extra)   { %{class="edit_book" id="edit_book_1" } }
        let(:content) { %{<div style="margin:0;padding:0;display:inline"><input name="_method" type="hidden" value="put" /></div>} }
        it_should_behave_like 'extended form_for'
      end
      
      context 'array' do
        before do
          @book.stubs(:to_key).returns(nil)
          @book.stubs(:new_record?).returns(true)
          @book.stubs(:id).returns(nil)
        end
        let(:book)    { [@book] }
        let(:extra)   { %{class="new_book" id="new_book" } }
        let(:content) { nil }
        it_should_behave_like 'extended form_for'
      end

    end

  end
end