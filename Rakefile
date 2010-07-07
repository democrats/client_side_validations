require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "client_side_validations"
    gem.summary     = %Q{Client Side Validations}
    gem.description = %Q{ORM and Framework agnostic Client Side Validations}
    gem.email       = "cardarellab@dnc.org"
    gem.homepage    = "http://github.com/dnclabs/client_side_validations"
    gem.authors     = ["Brian Cardarella"]
    gem.add_dependency 'validation_reflection', '>= 0.3.6'
    gem.add_dependency 'json', '1.4.3'
    gem.files       = Dir.glob("lib/**/*") + Dir.glob("javascript/lib/**/*") + Dir.glob("generators/**/*") + %w(LICENSE README.markdown)
    gem.test_files  = []
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'RSpec tests'
task :rspec do
  puts 'ActiveRecord 2.x'
  system('spec spec/active_record_2_spec.rb')
  
  puts 'ActiveModel 3.x'
  system('spec spec/active_model_3_spec.rb')
  
  puts 'ActionView 2.x'
  system('spec spec/action_view_2_spec.rb')

  puts 'ActionView 3.x'
  system('spec spec/action_view_3_spec.rb')
  
  puts 'Middleware'
  system('spec spec/middleware_spec.rb')
end

desc 'Default: the full test suite.'
task :default do
  system('rake jspec')
  system('rake rspec')
end

desc 'JSpec tests'
task :jspec do
  puts 'Javascript'
  system('jspec run javascript/jspec/rhino.js --rhino')
end