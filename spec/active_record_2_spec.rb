require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
gem 'activerecord', '2.3.8'
require 'active_record'
require 'client_side_validations'

describe 'Validations' do
  include ClientSideValidations::ORM

  before do
    define_abstract_ar(:Klass, ActiveRecord::Base)
  end

  after do
    Object.send(:remove_const, :Klass)
  end
  
  it_should_behave_like 'ActiveModel'
  it_should_behave_like 'ActiveRecord'
end