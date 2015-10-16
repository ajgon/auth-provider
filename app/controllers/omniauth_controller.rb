class OmniauthController < ApplicationController
  # rubocop:disable Metrics/MethodLength
  def setup
    app = request.subdomains.first ? Application.find_by_slug(request.subdomains.first) : Application.base
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
end
