# frozen_string_literal: true
require 'rails_helper'

# rubocop:disable RSpec/InstanceVariable
RSpec.describe OmniauthController, type: :controller do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:provider) { create(:provider, :google_oauth2) }

  context '#setup' do
    before(:each) do
      @request.host = "#{provider.application.slug}.#{request.domain}"
      @request.env['omniauth.strategy'] = OpenStruct.new(options: {})
    end

    it 'sets proper strategy for given subdomain and omniauth provider' do
      get :setup, provider: 'google_oauth2'

      expect(request.env['omniauth.strategy'].options[:client_id]).to eq provider.client_id
      expect(request.env['omniauth.strategy'].options[:client_secret]).to eq provider.client_secret
    end

    it 'does not set strategy if provider is wrong' do
      get :setup, provider: 'wrong_provider'

      expect(request.env['omniauth.strategy'].options).to eq({})
    end

    it 'does not set strategy if subdomain is wrong' do
      @request.host = "wrong-subdomain.#{request.domain}"

      get :setup, provider: 'google_oauth2'

      expect(request.env['omniauth.strategy'].options).to eq({})
    end
  end
end
# rubocop:enable RSpec/InstanceVariable
