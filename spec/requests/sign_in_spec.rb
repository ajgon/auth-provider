require 'rails_helper'

RSpec.describe 'sign in', type: :request do
  before(:each) do
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
  end

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

  it '#facebook' do
    OmniAuth.config.mock_auth[:facebook] =
      OmniAuth::AuthHash.new(
        provider: 'facebook',
        uid: '654321'
      )
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:facebook]
    provider = create(:provider, :facebook)

    get user_omniauth_authorize_url(:facebook, host: "#{provider.application.slug}.test.host")

    expect(response).to redirect_to(user_omniauth_callback_path(action: 'facebook'))
    expect(request.env['omniauth.auth'].provider).to eq 'facebook'
    expect(request.env['omniauth.auth'].uid).to eq '654321'
    expect(request.env['omniauth.strategy'].options[:client_id]).to eq provider.client_id
    expect(request.env['omniauth.strategy'].options[:client_secret]).to eq provider.client_secret

    OmniAuth.config.mock_auth[:facebook] = nil
  end
end
