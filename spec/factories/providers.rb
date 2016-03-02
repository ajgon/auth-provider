# frozen_string_literal: true
FactoryGirl.define do
  factory :provider do
    trait :google_oauth2 do
      type 'GoogleOauth2'
      client_id 'google_oauth2_client_id'
      client_secret 'google_oauth2_client_secret'
      enabled true
      applications { [create(:application)] }
    end

    trait :facebook do
      type 'Facebook'
      client_id 'facebook_client_id'
      client_secret 'facebook_client_secret'
      enabled true
      applications { [create(:application)] }
    end

    trait :twitter do
      type 'Twitter'
      client_id 'twitter_client_id'
      client_secret 'twitter_client_secret'
      enabled true
      applications { [create(:application)] }
    end

    trait :github do
      type 'Github'
      client_id 'github_client_id'
      client_secret 'github_client_secret'
      enabled true
      applications { [create(:application)] }
    end

    trait :instagram do
      type 'Instagram'
      client_id 'instagram_client_id'
      client_secret 'instagram_client_secret'
      enabled true
      applications { [create(:application)] }
    end

    trait :linkedin do
      type 'Linkedin'
      client_id 'linkedin_client_id'
      client_secret 'linkedin_client_secret'
      enabled true
      applications { [create(:application)] }
    end
  end
end
