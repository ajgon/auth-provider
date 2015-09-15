class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def omniauth_provider
    @user = User.from_omniauth(request.env['omniauth.auth'])

    render json: { auth: @user, provider: request.env['omniauth.auth'] }
  end

  Rails.configuration.omniauth_providers.each do |name, _options|
    send(:alias_method, name.to_sym, :omniauth_provider)
  end
end
