require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'active_model'
require 'client_side_validations'
gem 'activerecord', '~> 3.0'
require 'active_record'
require 'mongoid'

describe 'Validations' do
  include ClientSideValidations::ORM
  
  before do
    class Klass
      include ActiveModel::Validations
    end
  end
  
  after do
    Object.send(:remove_const, :Klass)
  end
  
  it_should_behave_like 'ActiveModel'
end

context 'ActiveRecord' do
  include ClientSideValidations::ORM
  
  before do
    define_abstract_ar(:Klass, ActiveRecord::Base)
  end

  after do
    Object.send(:remove_const, :Klass)
  end
  
  it_should_behave_like 'ActiveRecord'
end
  
context 'Mongoid' do
  include ClientSideValidations::ORM
  
  before do
    class Klass
      include Mongoid::Document
    end
  end
  
  after do
    Object.send(:remove_const, :Klass)
  end
  
  it 'should support validate_uniqueness_of' do
    Klass.class_eval { validates_uniqueness_of :string }
    instance = Klass.new
    expected_hash = { "uniqueness" => { "message" => "is already taken" } }
    result_hash   = ClientSideValidations::ORM::ValidateOptions.new(instance).validations_for(:string)
    result_hash.should == expected_hash
  end
end