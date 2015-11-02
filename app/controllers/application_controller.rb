class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_application
    @current_app ||= request.subdomains.first ? Application.find_by_slug(request.subdomains.first) : Application.base
  end
end
