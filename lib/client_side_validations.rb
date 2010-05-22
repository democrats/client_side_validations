require 'rubygems'

if defined?(ActiveRecord)
  if ActiveRecord::VERSION::MAJOR == 2
    require 'adapters/active_record_2_x'
  end
end