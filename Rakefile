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
    # gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency 'validation_reflection', '>= 0.3.6'
    gem.add_dependency 'json', '1.4.3'
    gem.files       = Dir.glob("lib/**/*") + Dir.glob("javascript/lib/**/*") + Dir.glob("generators/**/*") + %w(LICENSE README.markdown)
    gem.test_files  = []
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov    = true
end

task :spec => :check_dependencies
desc 'Default: run the specs.'
task :default do
  puts 'Javascript'
  system('jspec run javascript/jspec/rhino.js --rhino')
  
  puts 'ActiveRecord 2.x'
  system('spec spec/active_record_2_spec.rb')
  
  puts 'ActiveModel 3.x'
  system('spec spec/active_model_3_spec.rb')
  
  puts 'ActionView 2.x'
  system('spec spec/action_view_2_spec.rb')

  puts 'ActionView 3.x'
  system('spec spec/action_view_3_spec.rb')
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = "client_side_validations #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Dir['tasks/**/*.rake'].each { |t| load t }
