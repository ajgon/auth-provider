FactoryGirl.define do
  factory :application do
    name 'Test App'
    slug 'test-app'
    association :user
  end
end
