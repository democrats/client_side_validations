require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ar_client_side_validations'

describe "Validations to JSON" do
  
  before do
    class Klass < ActiveRecord::Base
      def self.columns() @columns ||= []; end

      def self.column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      end

      column :string, :string
      column :string_2, :string
      
      column :integer, :integer
    end
  end
  
  after do
    Object.send(:remove_const, :Klass)
  end
  
  it "should support validate_presence_of" do
    Klass.class_eval { validates_presence_of :string }
    instance      = Klass.new
    expected_json = { "required" => { "message" => "can't be blank"} }.to_json
    result_json   = instance.validation_to_json(:string)
    result_json.should == expected_json
  end
  
  it "should support format of" do
    Klass.class_eval { validates_format_of :string, :with => /\A\d\Z/i }
    instance      = Klass.new
    expected_json = { "format" => { "message" => "is invalid", "with" => "^\\d$" } }.to_json
    result_json   = instance.validation_to_json(:string)
    result_json.should == expected_json
  end
  
  it "should support different ways to write regex" do
    Klass.class_eval do
      validates_format_of :string, :with => /^\d$/i
      validates_format_of :string_2, :with => /\d/
    end
    instance        = Klass.new
    expected_json_1 = { "format" => { "message" => "is invalid", "with" => "^\\d$" } }.to_json
    expected_json_2 = { "format" => { "message" => "is invalid", "with" => "\\d" } }.to_json
    result_json_1   = instance.validation_to_json(:string)
    result_json_2   = instance.validation_to_json(:string_2)
    result_json_1.should == expected_json_1
    result_json_2.should == expected_json_2
  end
  
  it "should support minimum length of" do
    Klass.class_eval { validates_length_of :string, :minimum => 10 }
    instance      = Klass.new
    expected_json = { "minlength" => { "message" => "is too short (minimum is 10 characters)", "value" => 10 } }.to_json
    result_json   = instance.validation_to_json(:string)
    result_json.should == expected_json
  end

  it "should support maximum length of" do
    Klass.class_eval { validates_length_of :string, :maximum => 10 }
    instance      = Klass.new
    expected_json = { "maxlength" => { "message" => "is too long (maximum is 10 characters)", "value" => 10 } }.to_json
    result_json   = instance.validation_to_json(:string)
    result_json.should == expected_json
  end
  
  it "should support validations with conditionals" do
    Klass.class_eval do
      validates_presence_of :string, :if => :need_string?
      validates_presence_of :string_2, :unless => :need_string?
      validates_presence_of :integer, :if => :need_integer?
      
      def need_string?
        true
      end
      
      def need_integer?
        false
      end
    end
    
    instance        = Klass.new
    expected_json_1 = { "required" => { "message" => "can't be blank" } }.to_json
    result_json_1   = instance.validation_to_json(:string)
    result_json_1.should == expected_json_1
    
    expected_json_2 = { }.to_json
    result_json_2   = instance.validation_to_json(:string_2)
    result_json_2.should == expected_json_2
    
    expected_json_3 = { }.to_json
    result_json_3   = instance.validation_to_json(:integer)
    result_json_3.should == expected_json_3
  end
  
  it "should support validating the numericality of" do
    Klass.class_eval { validates_numericality_of :integer }
    instance      = Klass.new
    expected_json = { "digits" => { "message" => "is not a number" } }.to_json
    result_json   = instance.validation_to_json(:integer)
    result_json.should == expected_json
  end
  
  it "should strip out the AR callback options" do
    Klass.class_eval { validates_presence_of :string, :on => :create }
    instance      = Klass.new
    expected_json = { "required" => { "message" => "can't be blank"} }.to_json
    result_json   = instance.validation_to_json(:string)
    result_json.should == expected_json
  end
  
  it "should support multiple validations for the same method" do
    Klass.class_eval do
      validates_presence_of :integer
      validates_numericality_of :integer
    end
    
    instance      = Klass.new
    expected_json = { "required" => { "message" => "can't be blank" },
                      "digits"   => { "message" => "is not a number" } }.to_json
    result_json   = instance.validation_to_json(:integer)
    result_json.should == expected_json
  end
  
  context 'with custom validation messages' do
    before do
      add_translation(:en, :klass => { :attributes => { :string_2 => { :presence => "String_2" } } })
      
      Klass.class_eval do
        validates_presence_of :string, :message => "String"
        validates_presence_of :string_2, :message => :presence
      end
    end
    
    after do
      remove_translation(:en, :klass)
    end
    
    it 'should have a message of "String" for #string' do
      instance      = Klass.new
      expected_json = { "required" => { "message" => "String" } }.to_json
      result_json   = instance.validation_to_json(:string)
      result_json.should == expected_json
    end

    it 'should have a message of "String_2" for #string_2' do
      instance      = Klass.new
      expected_json = { "required" => { "message" => "String_2" } }.to_json
      result_json   = instance.validation_to_json(:string_2)
      result_json.should == expected_json
    end
  end
  
  context 'Other languages' do
    before do
      add_translation(:es, :klass => { :attributes => { :string => { :presence => "String-es" } } })
      
      Klass.class_eval do
        validates_presence_of :string, :message => :presence
      end
    end
    
    after do
      remove_translation(:es, :klass)
    end
    
    it 'should result in "String-es" for Spanish translations' do
      instance      = Klass.new
      expected_json = { "required" => { "message" => "String-es" } }.to_json
      result_json   = instance.validation_to_json(:string, :locale => :es)
      result_json.should == expected_json
    end
    
    it 'should result in "String-es" for Spanish translations when passed string "es" instead of symbol' do
      instance      = Klass.new
      expected_json = { "required" => { "message" => "String-es" } }.to_json
      result_json   = instance.validation_to_json(:string, :locale => "es")
      result_json.should == expected_json
    end
  end
  
  xit "should support the regular validate method" do
    Klass.class_eval do
      validate :do_something
      
      def do_something
        errors.add(:string, "test this out")
      end
    end
    
    instance = Klass.new
    # TODO: Unsupported right now
  end

  def add_translation(lang, hash)
    validations = {
      :activerecord => {
       :errors => {
         :models => hash
       }
      }
    }
    I18n.backend.store_translations(lang, validations)
  end
  
  def remove_translation(lang, key)
    model_validations = I18n.translate('activerecord.errors.models')
    model_validations.delete(key)
    validations = {
      :activerecord => {
        :errors => model_validations
      }
    }
    I18n.backend.store_translations(lang, validations)
  end
end