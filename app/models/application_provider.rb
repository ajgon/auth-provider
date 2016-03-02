# frozen_string_literal: true
class ApplicationProvider < ActiveRecord::Base
  belongs_to :application
  belongs_to :provider
end
