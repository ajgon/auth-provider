# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  it 'includes all enabled providers' do
    expect(described_class.omniauth_providers.map(&:to_s).sort)
      .to eq Rails.configuration.omniauth_providers.select { |_name, opts| opts['enabled'] }.keys.sort
  end

  it 'resolves user from omniauth data' do
    auth = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123456',
      info: {
        email: 'test-user-new@example.com',
        first_name: 'First',
        last_name: 'Last',
        image: 'avatar'
      }
    )

    user = described_class.from_omniauth(auth)

    expect(user.email).to eq 'test-user-new@example.com'
    expect(user.first_name).to eq 'First'
    expect(user.last_name).to eq 'Last'
    expect(user.avatar_url).to eq 'avatar'
  end
end
