module AbstractARModel
  def define_model(class_name, base, &block)
    klass = Class.new(base)
    Object.const_set(class_name, klass)

    klass.class_eval(&block) if block_given?

    @defined_constants ||= []
    @defined_constants << class_name

    klass
  end


  def define_abstract_ar(class_name, base, &block)
    klass = define_model(class_name, base, &block)
    klass.class_eval do
      def self.table_exists?
        false
      end
    
      def self.columns() @columns ||= []; end
  
      def self.column(name, sql_type = nil, default = nil, null = true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      end
    end
  end
  
end

Spec::Runner.configure do |config|
  config.include(AbstractARModel)
end