require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
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
end
