FactoryGirl.define do
  factory :template, class: Hash do
    initialize_with do
      { 
        :Parameters => {
          :Foo => { :Default => "bar" },
          :Go => {}
        }, 
        :Mappings => {}, 
        :Resources => {
          :TestResource => {}
        }, 
        :Outputs => {} 
      } 
    end
  end
end