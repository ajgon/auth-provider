require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should include all enabled providers' do
    expect(User.omniauth_providers.map(&:to_s).sort)
      .to eq Rails.configuration.omniauth_providers.select { |_name, opts| opts['enabled'] }.keys.sort
  end

  it 'should resolve user from omniauth data' do
    auth = OmniAuth::AuthHash.new(
      provider: 'google_oauth2',
      uid: '123456',
      info: {
        email: 'test@example.com',
        first_name: 'First',
        last_name: 'Last',
        image: 'avatar'
      }
    )

    user = User.from_omniauth(auth)

    expect(user.email).to eq 'test@example.com'
    expect(user.first_name).to eq 'First'
    expect(user.last_name).to eq 'Last'
    expect(user.avatar_url).to eq 'avatar'
  end
end
