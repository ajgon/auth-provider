module Api
  module V1
    class UsersController < ApiController
      skip_before_action :verify_authenticity_token
      skip_before_action :doorkeeper_authorize!, only: [:widget]
      respond_to :json

      def widget
        if current_application.uid != params[:client_id]
          head 400
          return
        end
        render json: { providers: provider_data }
      end

      def me
        respond_with current_resource_owner
      end

      private

      def provider_data
        current_application.providers.map do |provider|
          next if provider.type == 'AuthProvider'
          {
            url: login_provider_url(provider.slug, client_id: params[:client_id], response_type: params[:response_type],
                                                   state: params[:state], redirect_uri: params[:redirect_uri],
                                                   host: "#{current_application.slug}.#{request.domain}"),
            name: provider.name,
            slug: provider.slug
          }
        end.compact
      end
    end
  end
end
