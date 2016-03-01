# frozen_string_literal: true
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: Rails.configuration.omniauth_providers.keys.map(&:to_sym)

  has_many :oauth_application_users, dependent: :destroy
  has_many :applications, through: :oauth_application_users
  has_secure_token :client_id

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.avatar_url = auth.info.image || auth.info.avatar
      user.password = Devise.friendly_token[0, 20]
    end
  end
end
