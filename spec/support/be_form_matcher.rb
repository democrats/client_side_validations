module BeFormMatchers
  def be_form(options, html)
    BeFormMatcher.new(options, html)
  end
  
  class BeFormMatcher
    attr_accessor :options, :html
    
    def initialize(options, html)
      self.options = options
      self.html    = html
    end

    def matches?(subject)
      if rails3?
         @result = subject.form_for(*options) { }
         @result == html
      else
        subject.form_for(*options) { }
         @result = subject.output_buffer
         @result == html
      end
    end
    
    def failure_message
      %{Expected form does not match result.\nGot:      #{@result}\nExpected: #{html}}
    end
    
    private
    
    def rails3?
      version =
        if defined?(ActionPack::VERSION::MAJOR)
          ActionPack::VERSION::MAJOR
        end
      !version.blank? && version >= 3
    end
  end
end

Spec::Runner.configure do |config|
  config.include(BeFormMatchers)
end
