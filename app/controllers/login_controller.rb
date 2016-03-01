# frozen_string_literal: true
class LoginController < Devise::SessionsController
  include Doorkeeper::Helpers::Controller

  layout false
  skip_before_action :verify_authenticity_token, only: [:index, :authorize]
  # rescue_from Exception, with: :show_errors unless Rails.env.test?

  def index
    params[:response_type] ||= 'code'

    raise pre_auth.error_response.body.to_s unless pre_auth.authorizable?
    valid_request = validates_devise_authentication?
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
    @session_data = crypt.encrypt_and_sign(session.to_hash.to_json)
    return if valid_request

    render json: { error: I18n.t('devise.failure.not_found_in_database', authentication_keys: 'email') },
           status: :unauthorized
  end

  def provider
    session[:proxy] = {
      response_type: params[:response_type] || 'code',
      client_id: params[:client_id],
      redirect_uri: params[:redirect_uri],
      state: params[:state]
    }

    redirect_to user_omniauth_authorize_url(params[:provider], host: "#{current_application.slug}.#{request.domain}")
  end

  def authorize
    build_proper_session
    authorization_data = authorization.authorize
    warden.logout(:user)
    redirect_to authorization_data.redirect_uri
  end

  protected

  def build_proper_session
    if user_signed_in?
      # Cookie-based auth succeeded
      logger.info('[AuthProvider] Perfoming Cookie based authentication...')
      return
    end

    # Otherwise we need to rely on post params hack
    crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)
    session.update(JSON.parse(crypt.decrypt_and_verify(params[:session_data])))
    logger.info('[AuthProvider] Perfoming session_data param based authentication...')
  end

  # :nocov:
  def show_errors
    warden.logout(:user)
    render json: { error: 'Something went wrong. Please, try again.' }, status: :internal_server_error
  end
  # :nocov:

  private

  def validates_devise_authentication?
    allow_params_authentication!
    resource = warden.authenticate!(auth_options)
    return true if Application.joins(:users).find_by(id: server.client_via_uid.application.id).users.include?(resource)

    warden.logout(:user)
    false
  end

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#index" }
  end

  def pre_auth
    @pre_auth ||= Doorkeeper::OAuth::PreAuthorization.new(
      Doorkeeper.configuration, server.client_via_uid, params
    )
  end

  def authorization
    @authorization ||= strategy.request
  end

  def strategy
    @strategy ||= server.authorization_request pre_auth.response_type
  end
end
