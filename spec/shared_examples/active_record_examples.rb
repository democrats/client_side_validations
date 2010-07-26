shared_examples_for 'ActiveRecord' do
  it 'should support validate_uniqueness_of' do
    Klass.class_eval { validates_uniqueness_of :string }
    instance = Klass.new
    expected_hash = { "uniqueness" => { "message" => "has already been taken" } }
    result_hash   = instance.validations_to_hash(:string)
    result_hash.should == expected_hash
  end
end