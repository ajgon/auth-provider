# frozen_string_literal: true
module Admin
  class ApplicationController < ::ApplicationController
    layout 'admin'

    before_action :authorize_user

    protected

    def authorize_user
      authorize! :manage, :admin
    rescue CanCan::AccessDenied
      redirect_to root_url(subdomain: nil)
    end
  end
end
