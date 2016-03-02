# frozen_string_literal: true
class Provider < ActiveRecord::Base
  has_many :application_providers
  has_many :applications, through: :application_providers

  def name
    self.class.name.gsub(/[A-Z]/) { |capital| " #{capital}" }.strip
  end

  def slug
    type.underscore.to_s
  end
end
