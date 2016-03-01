# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SessionController, type: :controller do
  include Devise::TestHelpers

  let(:app) { create(:application) }
  let(:user) { app.owner }

  # rubocop:disable RSpec/InstanceVariable
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
  # rubocop:enable RSpec/InstanceVariable

  it 'signs in user with given code, and token assigned to base application' do
    token = Doorkeeper::AccessGrant.create!(
      resource_owner_id: user.id,
      application_id: Application.base.id,
      expires_in: 600,
      redirect_uri: session_url
    )

    get :index, code: token.token

    expect(warden.user).to eq user
  end

  it 'fails to sign in user with given code, and token assigned to base application' do
    token = Doorkeeper::AccessGrant.create!(
      resource_owner_id: user.id,
      application_id: app.id,
      expires_in: 600,
      redirect_uri: session_url
    )

    get :index, code: token.token

    expect(warden.user).to be_nil
  end
end
