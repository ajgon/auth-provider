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

  context '#widget' do
    it 'should return bad request if subdomain differs from application id' do
      app1 = create(:application)
      app2 = create(:application)
      allow(controller).to receive(:current_application) { app2 }

      get :widget, client_id: app1.uid

      expect(response.status).to eq 400
      expect(response.body).to eq ''

      app1.owner.destroy
      app2.owner.destroy
      app1.destroy
      app2.destroy
    end

    it 'should return provider data for given application' do
      app = create(:application)
      provider = GoogleOauth2.create
      provider2 = AuthProvider.create
      app.providers.push(provider)
      app.providers.push(provider2)
      app.save
      allow(controller).to receive(:current_application) { app }

      get :widget, client_id: app.uid

      expect(response.status).to eq 200
      expect(JSON.parse(response.body)).to eq(
        'providers' => [{
          'url' => "http://#{app.slug}.test.host/login/google_oauth2?client_id=#{app.uid}",
          'name' => 'Google',
          'slug' => 'google_oauth2'
        }]
      )

      provider2.destroy
      provider.destroy
      app.owner.destroy
      app.destroy
    end
  end
end
