class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def omniauth_provider
    @user = User.from_omniauth(request.env['omniauth.auth'])

    sign_in :user, @user
    redirect_to request.referer || root_path
  end

  Rails.configuration.omniauth_providers.each do |name, _options|
    send(:alias_method, name.to_sym, :omniauth_provider)
  end
end
