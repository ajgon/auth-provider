require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :controller do
  it 'should define all actions for enabled providers' do
    methods = (OmniauthCallbacksController.new.methods -
              Devise::OmniauthCallbacksController.new.methods - [:omniauth_provider]).map(&:to_s)
    expect(methods.sort).to eq Rails.configuration.omniauth_providers.keys.sort
  end

  it 'should return user data for given callback' do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123456',
      info: { email: 'test@example.com' }
    )
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]

    get :google_oauth2

    result = JSON.parse(response.body)

    expect(result['auth']['email']).to eq 'test@example.com'
    expect(result['auth']['provider']).to eq 'google_oauth2'
    expect(result['auth']['uid']).to eq '123456'
    expect(result['provider']['provider']).to eq 'google_oauth2'
    expect(result['provider']['uid']).to eq '123456'
    expect(result['provider']['info']['email']).to eq 'test@example.com'

    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end
