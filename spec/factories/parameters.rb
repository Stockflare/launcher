require 'launcher/parameters'

FactoryGirl.define do
  factory :parameters, class: Launcher::Parameters do
    initialize_with do
      new({ 
        :Foo => "bar",
        :Subnet => "subnet-adadq21rad",
        :Go => "fish",
        :Bar => "foo",
        :Easter => "egg"
      })
    end
  end
end