# frozen_string_literal: true
require 'rails_helper'

RSpec.describe LoginController, type: :controller do
  include Devise::TestHelpers

  let(:app) { create(:application) }
  let(:user) { app.owner }

  # rubocop:disable RSpec/InstanceVariable
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  # rubocop:enable RSpec/InstanceVariable

  context 'first step of verification' do
    it 'returns invalid user error if wrong credentials' do
      expect do
        post :index, user: { email: 'wrong@email.com', password: 'wrong password' },
                     client_id: app.uid, redirect_uri: app.redirect_uri
      end.to raise_error(UncaughtThrowError, 'uncaught throw :warden')
    end

    it 'returns invalid user error if user does not belong to the application' do
      user = create(:user)

      post :index, user: { email: user.email, password: 'testtest' },
                   client_id: app.uid, redirect_uri: app.redirect_uri

      expect(response.status).to eq 401
      expect(JSON.parse(response.body)).to eq('error' => 'Invalid email or password.')

      user.destroy
    end

    it 'throws error if no client_id and redirect_uri provided' do
      error_hash = {
        error: :invalid_client,
        error_description: 'Client authentication failed due to unknown client, no client authentication included, ' \
                           'or unsupported authentication method.'
      }

      expect do
        post :index, user: { email: user.email, password: 'testtest' }
      end.to raise_error(RuntimeError, error_hash.to_s)
    end

    it 'returns invalid user error if wrong params for doorkeeper' do
      error_hash = {
        error: :unsupported_response_type,
        error_description: 'The authorization server does not support this response type.'
      }

      expect do
        post :index, user: { email: user.email, password: 'testtest' },
                     response_type: 'wrong', client_id: app.uid, redirect_uri: app.redirect_uri
      end.to raise_error(RuntimeError, error_hash.to_s)
    end

    it 'successfullies redirect to second step if all params are correct' do
      post :index, user: { email: user.email, password: 'testtest' },
                   client_id: app.uid, redirect_uri: app.redirect_uri
      pre_auth = assigns['pre_auth']

      expect(response).to be_success
      expect(pre_auth.client.uid).to eq app.uid
      expect(pre_auth.redirect_uri).to eq app.redirect_uri
      expect(pre_auth.state).to eq nil
      expect(pre_auth.response_type).to eq 'code'
      expect(pre_auth.scope).to eq 'public'
    end
  end

  context 'second step of verification' do
    it 'redirects to callback url and sign out user when session exists' do
      sign_in :user, user

      post :authorize, client_id: app.uid, redirect_uri: app.redirect_uri, response_type: :code, scope: :public

      expect(response.headers['Location']).to match(/^#{app.redirect_uri}\?code=[0-9a-f]{64}$/)
      expect(warden.user).to be_falsey
    end

    it 'redirects to callback url and sign out user even with broken session (session_data hack)' do
      post :index, user: { email: user.email, password: 'testtest' },
                   client_id: app.uid, redirect_uri: app.redirect_uri

      allow(subject).to receive(:current_user) { nil }

      post :authorize, client_id: app.uid, redirect_uri: app.redirect_uri, response_type: :code, scope: :public,
                       session_data: assigns['session_data']

      expect(response.headers['Location']).to match(/^#{app.redirect_uri}\?code=[0-9a-f]{64}$/)
      expect(warden.user).to be_falsey
    end
  end
end
