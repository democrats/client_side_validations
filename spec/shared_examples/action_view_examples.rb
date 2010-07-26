share_examples_for 'extended form_for' do
  let(:js_vars) { %{<script type='text/javascript'>var #{object_name}_validate_options=#{@validate_options || '{"messages":{},"rules":{}}'};</script>} }
  
  context 'normal form_for options' do
    before do
      @options = [object, {:url => '/books'}]
    end
  
    it 'should retain default behavior' do
      no_data_csv = attributes.gsub(/data-csv="\w+"\s/,'')
      should be_form(@options, %{<form action="/books" #{no_data_csv}method="post">#{content}</form>})
    end
  end
  
  context 'with validations' do
    before do
      @options = [object, {:url => '/books', :validations => true}]
    end
  
    it 'should generate the proper javascript' do
      should be_form(@options, %{<form action="/books" #{attributes}method="post">#{content}</form>#{js_vars}})
    end
  end
  
  context 'with validate options' do
    before do
      Book.any_instance.stubs(:validate_options).returns({'rules' => {'name' => {'required' => true}}, 'messages' => {'name' => {'required' => 'Must be present'}}})
      @validate_options = %'{"messages":{"book[name]":{"required":"Must be present"}},"rules":{"book[name]":{"required":true}}}'
      @options = [object, {:url => '/books', :validations => true}]
    end
    
    it 'should generate the proper javascript' do
      should be_form(@options, %{<form action="/books" #{attributes}method="post">#{content}</form>#{js_vars}})
    end
  end
  
  context 'with validations overridden for a class' do
    before do
      class TestBook; end
      TestBook.any_instance.stubs(:validate_options).returns({"messages" => {}, "rules" => {}})
      model_name = mock("ModelName")
      model_name.stubs(:singular).returns('test_book')
      TestBook.stubs(:model_name).returns(model_name)
      @options = [object, {:url => '/books', :validations => TestBook}]
    end
  
    it 'should generate the proper javascript' do
      test_book_attributes = attributes.gsub(/data-csv="\w+"\s/,'data-csv="test_book" ')
      should be_form(@options, %{<form action="/books" #{test_book_attributes}method="post">#{content}</form><script type='text/javascript'>var test_book_validate_options={"messages":{},"rules":{}};</script>})
    end
  end
  
  context 'options' do
    before do
      ClientSideValidations.stubs(:default_options).returns({:test => "This"})
      @validate_options ||= '{"messages":{},"rules":{}}'
    end
    
    context 'using the default options' do
      before do
        @options = [object, {:url => '/books', :validations => true}]
        @validate_options.gsub!(/("rules":\{.*\})\}/) { |match| %'#{$1},"options":{"test":"This"}}' }
      end
      
      it 'should generate book_options JSON object' do
        should be_form(@options, %{<form action="/books" #{attributes}method="post">#{content}</form>#{js_vars}})
      end
    end
    
    context 'overriding the default options' do
      before do
        @options  = [object, {:url => '/books', :validations => { :options => { :test => "That" }}}]
        @validate_options.gsub!(/("rules":\{.*\})\}/) { |match| %'#{$1},"options":{"test":"That"}}' }
      end
      
      it 'should generate book_options JSON object' do
        should be_form(@options, %{<form action="/books" #{attributes}method="post">#{content}</form>#{js_vars}})
      end
    end
  end
  
end
