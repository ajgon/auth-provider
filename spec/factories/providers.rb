FactoryGirl.define do
  factory :provider do
    trait :google_oauth2 do
      type 'GoogleOauth2'
      client_id 'google_oauth2_client_id'
      client_secret 'google_oauth2_client_secret'
      enabled true
      association :application
    end

    trait :facebook do
      type 'Facebook'
      client_id 'facebook_client_id'
      client_secret 'facebook_client_secret'
      enabled true
      association :application
    end
  end
end
