require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'actionpack', '~> 3.0'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'client_side_validations'

share_examples_for 'extended form_for' do
  let(:book_validation_rules) { %{<script type='text/javascript'>var book_validation_rules={}</script>} }
  context 'normal form_for options' do
    before do
      @result = subject.form_for(book, :url => '/books') { }
    end

    it 'should retain default behavior' do
      @result.should == %{<form action="/books" #{extra}method="post">#{content}</form>}
    end
  end

  context 'with validations' do
    before do
      @result = subject.form_for(book, :url => '/books', :validations => true) { }
    end

    it 'should generate the proper javascript' do
      @result.should == %{<form action="/books" #{extra}method="post" object-csv="book">#{content}</form>#{book_validation_rules}}
    end
  end

  context 'with validations overridden for a class' do
    before do
      class TestBook; end
      TestBook.any_instance.stubs(:validations_to_json).returns('{}')
      @result = subject.form_for(book, :url => '/books', :validations => TestBook) { }
    end
  
    it 'should generate the proper javascript' do
      @result.should == %{<form action="/books" #{extra}method="post" object-csv="test_book">#{content}</form><script type='text/javascript'>var test_book_validation_rules={}</script>}
    end
  end
end

describe 'ActionView 3.x Form Helper' do
  context 'ActionView::Base' do
    before do
      class Book; end
      Book.any_instance.stubs(:validations_to_json).returns('{}')
    end

    subject do
      view = ActionView::Base.new
      view.stubs(:protect_against_forgery?).returns(false)
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
          @book.stubs(:persisted?).returns(true)
        end
        
        let(:book)  { @book }
        let(:extra) { %{class="edit_book" id="edit_book_1" } }
        let(:content) { %{<div style="margin:0;padding:0;display:inline"><input name="_method" type="hidden" value="put" /></div>} }
        it_should_behave_like 'extended form_for'
      end

      context 'array' do
        before do
          @book.stubs(:to_key).returns(nil)
        end
        let(:book)    { [@book] }
        let(:extra)   { %{class="new_book" id="new_book" } }
        let(:content) { nil }
        it_should_behave_like 'extended form_for'
      end

    end

  end
end