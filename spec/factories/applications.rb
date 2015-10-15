FactoryGirl.define do
  factory :application do
    name 'Dummy App'
    redirect_uri 'https://test.dev/callback'
    association :owner, factory: :user
  end
end
