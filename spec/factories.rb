FactoryGirl.define do
  factory :user do
    name                   "David Lastname"
    email                  "David@simulation.com"
    password               "foobar"
    password_confirmation  "foobar"
  end

  sequence :email do |n|
    "person#{n+3}@example.com"
  end

  factory :post do
    content "Some neato test data"
    association :user
  end

  factory :pair do
    association :user
    association :wing
  end
end
