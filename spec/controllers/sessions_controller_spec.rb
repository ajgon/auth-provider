require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  include Devise::TestHelpers

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context '#setup' do
    before(:each) do
      @provider = create(:provider, :google_oauth2)
      @request.host = "#{@provider.application.slug}.#{request.domain}"
      @request.env['omniauth.strategy'] = OpenStruct.new(options: {})
    end

    it 'should set proper strategy for given subdomain and omniauth provider' do
      get :setup, provider: 'google_oauth2'

      expect(request.env['omniauth.strategy'].options[:client_id]).to eq @provider.client_id
      expect(request.env['omniauth.strategy'].options[:client_secret]).to eq @provider.client_secret
    end

    it 'should not set strategy if provider is wrong' do
      get :setup, provider: 'wrong_provider'

      expect(request.env['omniauth.strategy'].options).to eq({})
    end

    it 'should not set strategy if subdomain is wrong' do
      @request.host = "wrong-subdomain.#{request.domain}"

      get :setup, provider: 'google_oauth2'

      expect(request.env['omniauth.strategy'].options).to eq({})
    end
  end

  context '#create' do
    before(:all) do
      @user = create(:user)
    end

    after(:all) do
      @user.destroy
    end

    it 'should sign in user and redirect via HTML request' do
      post :create, user: { email: @user.email, password: 'testtest' }

      expect(response).to redirect_to root_path
      expect(subject.current_user).to eq @user
    end

    it 'should return proper JSON via JS request' do
      xhr :post, :create, user: { email: @user.email, password: 'testtest' }
      result = JSON.parse(response.body)

      expect(response).to be_success
      expect(result['user']['email']).to eq @user.email
      expect(result['location']).to eq root_path
    end
  end
end
