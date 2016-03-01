# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :controller do
  include Devise::TestHelpers

  it 'defines all actions for enabled providers' do
    methods = (described_class.new.methods -
              Devise::OmniauthCallbacksController.new.methods - [:omniauth_provider]).map(&:to_s)
    expect(methods.sort).to eq Rails.configuration.omniauth_providers.keys.sort
  end

  # rubocop:disable RSpec/InstanceVariable
  it 'returns user data for given callback' do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123456',
      info: { email: 'test@example.com' }
    )
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]

    get :google_oauth2

    expect(response).to redirect_to root_path
    expect(subject.current_user.email).to eq 'test@example.com'

    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
  # rubocop:enable RSpec/InstanceVariable
end
