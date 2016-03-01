# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def omniauth_provider
    @token = nil
    @user = User.from_omniauth(request.env['omniauth.auth'])
    handle_auth_proxy if session[:proxy]

    sign_in :user, @user
    redirect_to @redirect_uri || request.referer || root_path
  end

  private

  def handle_auth_proxy
    @token = Doorkeeper::AccessToken.create!(
      application_id: Application.find_by_uid(session[:proxy]['client_id']).id,
      resource_owner_id: @user.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      scopes: Doorkeeper.configuration.default_scopes.to_a.join(',')
    )
    build_redirect_uri
    session.delete(:proxy)
  end

  def build_redirect_uri
    pre_auth = Doorkeeper::OAuth::PreAuthorization.new(
      Doorkeeper.configuration,
      Doorkeeper::OAuth::Client.find(session[:proxy]['client_id']),
      HashWithIndifferentAccess.new(session[:proxy])
    )
    auth = OpenStruct.new(token: @token)
    is_token = session[:proxy]['response_type'] == 'token'

    @redirect_uri = Doorkeeper::OAuth::CodeResponse.new(pre_auth, auth, response_on_fragment: is_token).redirect_uri
  end

  Rails.configuration.omniauth_providers.each do |name, _options|
    send(:alias_method, name.to_sym, :omniauth_provider)
  end
end
