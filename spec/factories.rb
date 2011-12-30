FactoryGirl.define do
  factory :user do
    name                   "David Lastname"
    email                  "David@simulation.com"
    password               "foobar"
    password_confirmation  "foobar"
  end
end
