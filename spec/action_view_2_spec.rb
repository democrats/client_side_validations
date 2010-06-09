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
    
    context 'only the url' do
      before do
        subject.form_for('book', :url => '/books', :validations => { :url => '/books/new.json' }) { }
        @result = subject.output_buffer
      end
      
      it 'should generate the proper javascript' do
        @result.should == %{<form action="/books" data-csv-url="/books/new.json" method="post"></form>}
      end
    end
    
    context 'only the url' do
      before do
        subject.form_for('book', :url => '/books', :validations => { :url => '/books/new.json', :adapter => 'jquery.validate' }) { }
        @result = subject.output_buffer
      end
      
      it 'should generate the proper javascript' do
        @result.should == %{<form action="/books" data-csv-adapter="jquery.validate" data-csv-url="/books/new.json" method="post"></form>}
      end
    end

    context 'not including the :url' do
      it 'should raise an error' do
        expect {
          subject.form_for('book', :url => '/books', :validations => { :adapter => 'jquery.validate' }) { }
        }.to raise_error
      end
    end
    
  end
end