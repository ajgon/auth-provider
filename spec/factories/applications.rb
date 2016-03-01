# frozen_string_literal: true
FactoryGirl.define do
  factory :application do
    name 'Dummy App'
    redirect_uri 'https://test.dev/callback'
    association :owner, factory: :user

    trait :no_owner do
      owner nil
    end
  end
end
