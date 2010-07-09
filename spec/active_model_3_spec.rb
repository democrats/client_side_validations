require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'active_model'
require 'client_side_validations'
gem 'activerecord', '~> 3.0'
require 'active_record'
require 'mongoid'

describe 'Validations' do
  before do
    class Klass
      include ActiveModel::Validations
    end
  end
  
  after do
    Object.send(:remove_const, :Klass)
  end
  
  describe 'to hash' do
    it "should support validate_presence_of" do
      Klass.class_eval { validates_presence_of :string }
      instance      = Klass.new
      expected_hash = { "presence" => { "message" => "can't be blank"} }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end
  
    it "should support validates_format_of of" do
      Klass.class_eval { validates_format_of :string, :with => /\A\d\Z/i }
      instance      = Klass.new
      expected_hash = { "format" => { "message" => "is invalid", "with" => "^\\d$" } }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end
  
    it "should support different ways to write regex" do
      Klass.class_eval do
        validates_format_of :string, :with => /^\d$/i
        validates_format_of :string_2, :with => /\d/
      end
      instance        = Klass.new
      expected_hash_1 = { "format" => { "message" => "is invalid", "with" => "^\\d$" } }
      expected_hash_2 = { "format" => { "message" => "is invalid", "with" => "\\d" } }
      result_hash_1   = instance.validation_to_hash(:string)
      result_hash_2   = instance.validation_to_hash(:string_2)
      result_hash_1.should == expected_hash_1
      result_hash_2.should == expected_hash_2
    end
  
    it "should support minimum validates_length_of of" do
      Klass.class_eval { validates_length_of :string, :minimum => 10 }
      instance      = Klass.new
      expected_hash = { "length" => { "message" => "is too short (minimum is 10 characters)", "minimum" => 10 } }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end

    it "should support maximum validates_length_of of" do
      Klass.class_eval { validates_length_of :string, :maximum => 10 }
      instance      = Klass.new
      expected_hash = { "length" => { "message" => "is too long (maximum is 10 characters)", "maximum" => 10 } }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
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
      expected_hash_1 = { "presence" => { "message" => "can't be blank" } }
      result_hash_1   = instance.validation_to_hash(:string)
      result_hash_1.should == expected_hash_1
    
      expected_hash_2 = { }
      result_hash_2   = instance.validation_to_hash(:string_2)
      result_hash_2.should == expected_hash_2
    
      expected_hash_3 = { }
      result_hash_3   = instance.validation_to_hash(:integer)
      result_hash_3.should == expected_hash_3
    end
  
    it "should support validating the validates_numericality_of" do
      Klass.class_eval { validates_numericality_of :integer }
      instance      = Klass.new
      expected_hash = { "numericality" => { "message" => "is not a number" } }
      result_hash   = instance.validation_to_hash(:integer)
      result_hash.should == expected_hash
    end
    
    it 'should support validates_confirmation_of' do
      Klass.class_eval { validates_confirmation_of :string }
      instance      = Klass.new
      expected_hash = { "confirmation" => { "message" => "doesn't match confirmation" } }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end
  
    it "should strip out the AR callback options" do
      Klass.class_eval { validates_presence_of :string, :on => :create }
      instance      = Klass.new
      expected_hash = { "presence" => { "message" => "can't be blank"} }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end
  
    it "should support multiple validations for the same method" do
      Klass.class_eval do
        validates_presence_of :integer
        validates_numericality_of :integer
      end
    
      instance      = Klass.new
      expected_hash = { "presence" => { "message" => "can't be blank" },
                        "numericality" => { "message" => "is not a number" } }
      result_hash   = instance.validation_to_hash(:integer)
      result_hash.should == expected_hash
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
        expected_hash = { "presence" => { "message" => "String" } }
        result_hash   = instance.validation_to_hash(:string)
        result_hash.should == expected_hash
      end

      it 'should have a message of "String_2" for #string_2' do
        instance      = Klass.new
        expected_hash = { "presence" => { "message" => "String_2" } }
        result_hash   = instance.validation_to_hash(:string_2)
        result_hash.should == expected_hash
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
        expected_hash = { "presence" => { "message" => "String-es" } }
        result_hash   = instance.validation_to_hash(:string, :locale => :es)
        result_hash.should == expected_hash
      end
    
      it 'should result in "String-es" for Spanish translations when passed string "es" instead of symbol' do
        instance      = Klass.new
        expected_hash = { "presence" => { "message" => "String-es" } }
        result_hash   = instance.validation_to_hash(:string, :locale => "es")
        result_hash.should == expected_hash
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
        :errors => {
          :models => hash
        }
      }
      I18n.backend.store_translations(lang, validations)
    end
  
    def remove_translation(lang, key)
      model_validations = I18n.translate('errors.models')
      model_validations.delete(key)
      validations = {
        :errors => model_validations
      }
      I18n.backend.store_translations(lang, validations)
    end
  end

  describe 'to JSON' do
    it "should support a sinlgle validation" do
      Klass.class_eval do
        validates_presence_of :string
      end
    
      instance      = Klass.new
      expected_json = {:string => { "presence" => { "message" => "can't be blank" } } }.to_json
      result_json   = instance.validations_to_json
      result_json.should == expected_json
    end

    it "should support multiple validations on the same field" do
      Klass.class_eval do
        validates_presence_of :number
        validates_numericality_of :number
      end
    
      instance      = Klass.new
      expected_json = {:number => { "presence" => { "message" => "can't be blank" }, "numericality" => { "message" => "is not a number" } } }.to_json
      result_json   = instance.validations_to_json
      result_json.should == expected_json
    end
  
    it "should support single validations on different fields" do
      Klass.class_eval do
        validates_presence_of :string_1
        validates_presence_of :string_2
      end
    
      instance      = Klass.new
      expected_json = {:string_1 => { "presence" => { "message" => "can't be blank" } },
                       :string_2 => { "presence" => { "message" => "can't be blank" } } }.to_json
      result_json   = instance.validations_to_json
      result_json.should == expected_json
    end
  
    it "should support multiple validations on different fields" do
      Klass.class_eval do
        validates_presence_of     :number_1
        validates_numericality_of :number_1
        validates_presence_of     :number_2
        validates_numericality_of :number_2
      end
    
      instance      = Klass.new
      expected_json = {:number_1 => { "presence" => { "message" => "can't be blank" }, "numericality" => { "message" => "is not a number" } },
                       :number_2 => { "presence" => { "message" => "can't be blank" }, "numericality" => { "message" => "is not a number" } } }.to_json
      result_json   = instance.validations_to_json
      result_json.should == expected_json
    end
  end
  
  describe 'fields' do
    it 'should only return field names that have validations' do
      Klass.class_eval do
        validates_presence_of     :number_1
        validates_numericality_of :number_2
      end
    
      instance        = Klass.new
      expected_fields = [:number_1, :number_2]
      result_fields   = instance.validation_fields.map { |k| k.to_s }.sort.map { |k| k.to_sym }
      result_fields.should == expected_fields
    end
    
    it 'should only return a single field name if assigned multiple validations' do
      Klass.class_eval do
        validates_presence_of     :number_1
        validates_numericality_of :number_1
      end
      
      instance        = Klass.new
      expected_fields = [:number_1]
      result_fields   = instance.validation_fields
      result_fields.should == expected_fields
    end
  end
end

describe 'Uniqueness' do
  context 'ActiveRecord' do
    before do
      class Klass < ActiveRecord::Base
        def self.table_exists?
          false
        end
      
        def self.columns() @columns ||= []; end
    
        def self.column(name, sql_type = nil, default = nil, null = true)
          columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
        end
      end
    end
  
    after do
      Object.send(:remove_const, :Klass)
    end
  
    it 'should support validate_uniqueness_of' do
      Klass.class_eval { validates_uniqueness_of :string }
      instance = Klass.new
      expected_hash = { "uniqueness" => { "message" => "has already been taken" } }
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end
  end
  
  context 'Mongoid' do
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
      result_hash   = instance.validation_to_hash(:string)
      result_hash.should == expected_hash
    end
  end
end