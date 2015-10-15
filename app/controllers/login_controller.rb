class LoginController < Devise::SessionsController
  include Doorkeeper::Helpers::Controller

  layout false
  skip_before_action :verify_authenticity_token, only: [:index]
  rescue_from Exception, with: :show_errors unless Rails.env.test?

  def index
    params[:response_type] ||= 'code'
    handle_devise_authentication

    if pre_auth.authorizable?
      render :index
    else
      fail pre_auth.error_response.body.to_s
    end
  end

  def authorize
    authorization_data = authorization.authorize
    warden.logout(:user)
    redirect_to authorization_data.redirect_uri
  end

  protected

  # :nocov:
  def show_errors
    warden.logout(:user)
    render json: { error: 'Something went wrong. Please, try again.' }, status: :internal_server_error
  end
  # :nocov:

  private

  def handle_devise_authentication
    allow_params_authentication!
    resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
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
