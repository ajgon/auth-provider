# class SessionsController < Devise::SessionsController
#
#
#   def create
#     self.resource = warden.authenticate!(auth_options)
#     set_flash_message(:notice, :signed_in) if is_flashing_format?
#     sign_in(resource_name, resource)
#     yield resource if block_given?
#
#     if request.xhr?
#       render(json: { user: resource.as_json, location: request.env['HTTP_X_AUTHPROVIDER_CALLBACKURL'] })
#     else
#       respond_with resource, location: after_sign_in_path_for(resource)
#     end
#   end
# end
