require 'rails_helper'

RSpec.describe 'sign in', type: :request do
  before(:each) do
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
  end

  # OAuth2
  it '#google' do
    OmniAuth.config.mock_auth[:google_oauth2] =
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid: '123456'
      )
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
    provider = create(:provider, :google_oauth2)

    get user_omniauth_authorize_url(:google_oauth2, host: "#{provider.application.slug}.test.host")

    expect(response).to redirect_to(user_omniauth_callback_path(action: 'google_oauth2'))
    expect(request.env['omniauth.auth'].provider).to eq 'google_oauth2'
    expect(request.env['omniauth.auth'].uid).to eq '123456'
    expect(request.env['omniauth.strategy'].options[:client_id]).to eq provider.client_id
    expect(request.env['omniauth.strategy'].options[:client_secret]).to eq provider.client_secret

    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  # OAuth1
  it '#twitter' do
    OmniAuth.config.mock_auth[:twitter] =
      OmniAuth::AuthHash.new(
        provider: 'twitter',
        uid: '654321'
      )
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
    provider = create(:provider, :twitter)

    get user_omniauth_authorize_url(:twitter, host: "#{provider.application.slug}.test.host")

    expect(response).to redirect_to(user_omniauth_callback_path(action: 'twitter'))
    expect(request.env['omniauth.auth'].provider).to eq 'twitter'
    expect(request.env['omniauth.auth'].uid).to eq '654321'
    expect(request.env['omniauth.strategy'].options[:consumer_key]).to eq provider.client_id
    expect(request.env['omniauth.strategy'].options[:consumer_secret]).to eq provider.client_secret

    OmniAuth.config.mock_auth[:twitter] = nil
  end
end
