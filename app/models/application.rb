class Application < ActiveRecord::Base
  belongs_to :user
  has_many :providers

  acts_as_url :name, url_attribute: :slug

  alias_method :to_param, :slug
end
