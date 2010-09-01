module RubyVersionChecker
  def ruby18?
    ruby_split[0] == '1' && ruby_split[1] == '8'
  end
  
  def ruby19?
    ruby_split[0] == '1' && ruby_split[1] == '9'
  end
  
  def ruby_split
    RUBY_VERSION.split('.')
  end
end

Spec::Runner.configure do |config|
  config.include(RubyVersionChecker)
end