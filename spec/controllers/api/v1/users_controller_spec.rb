require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do
  it 'should get current user info' do
    user = create(:user)
    token = double(resource_owner_id: user.id, acceptable?: true)
    allow(controller).to receive(:doorkeeper_token) { token }

    get :me, format: :json

    expect(response.status).to eq 200
    expect(JSON.parse(response.body)['email']).to eq user.email
  end
end
