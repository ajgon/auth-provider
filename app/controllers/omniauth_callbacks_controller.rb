# frozen_string_literal: true
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def omniauth_provider
    handle_auth_proxy if proxy_session.present?

    sign_in :user, current_resource_owner
    redirect_to @redirect_uri || request.referer || root_path
  end

  private

  def handle_auth_proxy
    request = if response_type_token?
                Doorkeeper::OAuth::TokenRequest.new(pre_auth, current_resource_owner)
              else
                Doorkeeper::OAuth::CodeRequest.new(pre_auth, current_resource_owner)
              end

    @redirect_uri = request.authorize.redirect_uri
    session.delete(:proxy)
  end

  def current_resource_owner
    User.from_omniauth(request.env['omniauth.auth'])
  end

  def proxy_session
    HashWithIndifferentAccess.new(session[:proxy])
  end

  def pre_auth
    Doorkeeper::OAuth::PreAuthorization.new(
      Doorkeeper.configuration,
      Doorkeeper::OAuth::Client.find(proxy_session[:client_id]),
      proxy_session
    )
  end

  def response_type_token?
    proxy_session[:response_type] == 'token'
  end

  Rails.configuration.omniauth_providers.each do |name, _options|
    send(:alias_method, name.to_sym, :omniauth_provider)
  end
end
