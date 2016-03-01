# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'sign in', type: :request do
  include Warden::Test::Helpers
  Warden.test_mode!

  before(:each) do
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
  end

  after(:each) do
    Warden.test_reset!
  end

  # AuthProvider itself
  context '#authprovider (self)' do
    it 'step1 /login/usernamepassword' do
      app = create(:application)
      user = app.owner

      post login_url, user: { email: user.email, password: 'testtest' },
                      client_id: app.uid, redirect_uri: app.redirect_uri, state: 'dummy_state'

      doc = Nokogiri::HTML(response.body)
      expect(doc.css('form').first.attr('action')).to match(%r{/login/authorize\?response_type=code$})
      expect(doc.css('[name="client_id"]').first.attr('value')).to eq app.uid
      expect(doc.css('[name="redirect_uri"]').first.attr('value')).to eq app.redirect_uri
      expect(doc.css('[name="state"]').first.attr('value')).to eq 'dummy_state'
      expect(doc.css('[name="response_type"]').first.attr('value')).to eq 'code'
      expect(doc.css('[name="scope"]').first.attr('value')).to eq 'public'
      expect(request.env['warden'].user).to eq user

      app.destroy
      user.destroy
    end

    it 'step2 /login/authorize (code)' do
      app = create(:application)
      user = app.owner
      login_as user, scope: :user

      post login_authorize_url, client_id: app.uid, redirect_uri: app.redirect_uri, state: 'dummy_state',
                                response_type: 'code', scope: 'public'

      expect(response.headers['Location']).to match(/^#{app.redirect_uri}\?code=[0-9a-f]{64}\&state=dummy_state$/)
      expect(request.env['warden'].user).to be_falsey

      app.destroy
      user.destroy
    end

    it 'step2 /login/authorize (token and cookie)' do
      app = create(:application)
      user = app.owner
      login_as user, scope: :user

      post login_authorize_url, client_id: app.uid, redirect_uri: app.redirect_uri, state: 'dummy_state',
                                response_type: 'token', scope: 'public'

      expect(response.headers['Location'])
        .to match(/^#{app.redirect_uri}#access_token=[0-9a-f]{64}&token_type=bearer&expires_in=7200&state=dummy_state$/)
      expect(request.env['warden'].user).to be_falsey

      app.destroy
      user.destroy
    end

    it 'step2 /login/authorize (token and form param fallback)' do
      app = create(:application)
      user = app.owner

      post login_url, user: { email: user.email, password: 'testtest' },
                      client_id: app.uid, redirect_uri: app.redirect_uri, state: 'dummy_state'

      doc = Nokogiri::HTML(response.body)
      session_data = doc.css('[name="session_data"]').first.attr('value')

      logout :user
      post login_authorize_url, client_id: app.uid, redirect_uri: app.redirect_uri, state: 'dummy_state',
                                response_type: 'token', scope: 'public', session_data: session_data

      expect(User.find(session['warden.user.user.key'].first.first)).to eq user

      app.destroy
      user.destroy
    end

    it 'step3 #callback' do
      user = create(:user)
      OmniAuth.config.mock_auth[:auth_provider] =
        OmniAuth::AuthHash.new(
          provider: 'auth_provider',
          uid: '123456',
          info: {
            email: user.email
          }
        )
      Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:auth_provider]

      get user_omniauth_callback_url(:auth_provider)

      expect(response).to redirect_to root_path
      expect(request.env['warden'].user).to eq user

      OmniAuth.config.mock_auth[:auth_provider] = nil
      user.destroy
    end
  end

  context '#google (external source)' do
    context '#provider and #callback' do
      it 'response_type = token' do
        app = create(:application)
        user = app.owner
        OmniAuth.config.mock_auth[:google_oauth2] =
          OmniAuth::AuthHash.new(
            provider: 'google_oauth2',
            uid: '123456',
            info: {
              email: user.email
            }
          )
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]

        get login_provider_url(:google_oauth2, host: "#{app.slug}.test.host"),
            response_type: 'token', state: 'dummy_state', client_id: app.uid, redirect_uri: app.redirect_uri

        expect(session[:proxy][:response_type]).to eq 'token'
        expect(session[:proxy][:client_id]).to eq app.uid
        expect(session[:proxy][:redirect_uri]).to eq app.redirect_uri
        expect(session[:proxy][:state]).to eq 'dummy_state'
        expect(response).to redirect_to user_omniauth_authorize_url(:google_oauth2, host: "#{app.slug}.test.host")

        get user_omniauth_callback_url(:google_oauth2, host: "#{app.slug}.test.host")
        token = Doorkeeper::AccessToken.last

        expect(response).to redirect_to "#{app.redirect_uri}#access_token=#{token.token}&token_type=bearer" \
                                        "&expires_in=#{token.expires_in}&state=dummy_state"
        expect(request.env['warden'].user).to eq user
        expect(session[:proxy]).to be_falsey

        OmniAuth.config.mock_auth[:google_oauth2] = nil
        app.destroy
        user.destroy
      end

      it 'response_type = code' do
        app = create(:application)
        user = app.owner
        OmniAuth.config.mock_auth[:google_oauth2] =
          OmniAuth::AuthHash.new(
            provider: 'google_oauth2',
            uid: '123456',
            info: {
              email: user.email
            }
          )
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]

        get login_provider_url(:google_oauth2, host: "#{app.slug}.test.host"),
            response_type: 'code', state: 'dummy_state', client_id: app.uid, redirect_uri: app.redirect_uri

        expect(session[:proxy][:response_type]).to eq 'code'
        expect(session[:proxy][:client_id]).to eq app.uid
        expect(session[:proxy][:redirect_uri]).to eq app.redirect_uri
        expect(session[:proxy][:state]).to eq 'dummy_state'
        expect(response).to redirect_to user_omniauth_authorize_url(:google_oauth2, host: "#{app.slug}.test.host")

        get user_omniauth_callback_url(:google_oauth2, host: "#{app.slug}.test.host")
        token = Doorkeeper::AccessToken.last

        expect(response).to redirect_to "#{app.redirect_uri}?code=#{token.token}&state=dummy_state"
        expect(request.env['warden'].user).to eq user
        expect(session[:proxy]).to be_falsey

        OmniAuth.config.mock_auth[:google_oauth2] = nil
        app.destroy
        user.destroy
      end
    end
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
