class SessionsController < Devise::SessionsController
  # rubocop:disable Metrics/MethodLength
  def setup
    app = Application.find_by_slug(request.subdomains.first)
    if app.present?
      provider = app.providers.find_by(type: params[:provider].classify)
      if provider.present? && provider.enabled?
        request.env['omniauth.strategy'].options[:client_id] = provider.client_id
        request.env['omniauth.strategy'].options[:client_secret] = provider.client_secret
        # For OAuth1.x
        request.env['omniauth.strategy'].options[:consumer_key] = provider.client_id
        request.env['omniauth.strategy'].options[:consumer_secret] = provider.client_secret
      end
    end
    render text: 'Omniauth setup phase.', status: 404
  end

  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?

    if request.xhr?
      render(json: { user: resource.as_json, location: after_sign_in_path_for(resource) })
    else
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
