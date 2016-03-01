# frozen_string_literal: true
class OauthApplicationUser < ActiveRecord::Base
  belongs_to :application, foreign_key: :oauth_application_id
  belongs_to :user
end
