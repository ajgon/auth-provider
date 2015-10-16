module Api
  module V1
    class UsersController < ApiController
      skip_before_action :verify_authenticity_token
      before_action :doorkeeper_authorize!
      respond_to :json

      def me
        respond_with current_resource_owner
      end
    end
  end
end
