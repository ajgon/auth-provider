class SessionsController < ApplicationController
  def setup
    app = Application.find_by_slug(request.subdomains.first)
    if app.present?
      provider = app.providers.find_by(type: params[:provider].classify)
      if provider.present? && provider.enabled?
        request.env['omniauth.strategy'].options[:client_id] = provider.client_id
        request.env['omniauth.strategy'].options[:client_secret] = provider.client_secret
      end
    end
    render text: 'Omniauth setup phase.', status: 404
  end
end
