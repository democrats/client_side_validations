begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  require 'spec'
end
begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

namespace :spec do
  desc "Run ActiveRecord specs"
  Spec::Rake::SpecTask.new(:active_record) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.ruby_opts << "-r #{File.join(File.dirname(__FILE__), *%w[gem_loader load_active_support])}"
  end

  desc "Run ActiveModel specs"
  Spec::Rake::SpecTask.new(:active_model) do |t|
    t.spec_opts = ['--options', "spec/spec.opts"]
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.ruby_opts << "-r #{File.join(File.dirname(__FILE__), *%w[gem_loader load_tzinfo_gem])}"
  end
end
