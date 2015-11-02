class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def omniauth_provider
    @token = nil
    @user = User.from_omniauth(request.env['omniauth.auth'])
    handle_auth_proxy if session[:proxy]

    sign_in :user, @user
    if @token
      redirect_to "#{@redirect_uri}#access_token=#{@token.token}&token_type=bearer&expires_in=#{@token.expires_in}"
    else
      redirect_to request.referer || root_path
    end
  end

  private

  def handle_auth_proxy
    @redirect_uri = session[:proxy]['redirect_uri']
    @token = Doorkeeper::AccessToken.create!(
      application_id: Application.find_by_uid(session[:proxy]['client_id']).id,
      resource_owner_id: @user.id,
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      scopes: Doorkeeper.configuration.default_scopes.to_a.join(',')
    )
    session.delete(:proxy)
  end

  Rails.configuration.omniauth_providers.each do |name, _options|
    send(:alias_method, name.to_sym, :omniauth_provider)
  end
end
