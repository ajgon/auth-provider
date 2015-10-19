module Api
  module V1
    class ApiController < ApplicationController
      protected

      def current_resource_owner
        return unless doorkeeper_token
        user = User.find(doorkeeper_token.resource_owner_id)
        user.as_json.except('id').merge('uid' => user.client_id, 'provider' => 'auth_provider')
      end
    end
  end
end
