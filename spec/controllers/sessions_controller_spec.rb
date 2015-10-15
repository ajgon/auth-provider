# require 'rails_helper'
#
# RSpec.describe SessionsController, type: :controller do
#   include Devise::TestHelpers
#
#   before(:each) do
#     @request.env["devise.mapping"] = Devise.mappings[:user]
#   end
#
#   context '#create' do
#     before(:all) do
#       @user = create(:user)
#     end
#
#     after(:all) do
#       @user.destroy
#     end
#
#     it 'should sign in user and redirect via HTML request' do
#       post :create, user: { email: @user.email, password: 'testtest' }
#
#       expect(response).to redirect_to root_path
#       expect(subject.current_user).to eq @user
#     end
#
#     it 'should return proper JSON via JS request' do
#       xhr :post, :create, user: { email: @user.email, password: 'testtest' }
#       result = JSON.parse(response.body)
#
#       expect(response).to be_success
#       expect(result['user']['email']).to eq @user.email
#       expect(result['location']).to eq root_path
#     end
#   end
# end
