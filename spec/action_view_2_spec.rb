require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'actionpack', '~> 2.0'
require 'action_pack'
require 'action_view'
require 'client_side_validations'

describe 'ActionView 2.x Form Helper' do
  context 'ActionView::Base' do
    subject do
      view = ActionView::Base.new
      view.stub!(:protect_against_forgery?).and_return(false)
      view.output_buffer = ActiveSupport::SafeBuffer.new
      view.stub!(:controller)
      view
    end
    
    context 'normal form_for options' do
      before do
        subject.form_for('book', :url => '/books') { }
        @result = subject.output_buffer
      end
      
      it 'should retain default behavior' do
        @result.should == %{<form action="/books" method="post"></form>}
      end
    end
    
    context 'with validations default' do
      before do
        subject.form_for('book', :url => '/books', :validations => true) { }
        @result = subject.output_buffer
      end
      
      it 'should generate the proper javascript' do
        @result.should == %{<form action="/books" method="post" object-csv="book"></form>}
      end
    end

    context 'with validations overridden for a class' do
      before do
        class TestBook; end
        subject.form_for('book', :url => '/books', :validations => TestBook) { }
        @result = subject.output_buffer
      end
      
      it 'should generate the proper javascript' do
        @result.should == %{<form action="/books" method="post" object-csv="test_book"></form>}
      end
    end
  end
end