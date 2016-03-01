# frozen_string_literal: true
# This is session handling for auth-provider itself
class SessionController < ApplicationController
  def index
    # @todo fix it someday to proper call
    if Doorkeeper::AccessGrant.where(application_id: Application.base.id).by_token(params[:code]).present?
      sign_in :user, User.find(Doorkeeper::AccessGrant.by_token(params[:code]).resource_owner_id)
    end
    redirect_to root_url
  end
end
