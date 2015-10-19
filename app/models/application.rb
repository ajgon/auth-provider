class Application < Doorkeeper::Application
  has_many :providers
  has_many :oauth_application_users, foreign_key: :oauth_application_id, dependent: :destroy
  has_many :users, through: :oauth_application_users

  acts_as_url :name, url_attribute: :slug, blacklist: %w(app new www dev staging admin)
  alias_method :to_param, :slug

  before_save :clean_allowed_cors, :ensure_that_owner_is_mapped_through

  scope :with_allowed_cors, lambda { |callback_url|
    where(
      arel_table[:allowed_cors].matches_any(
        ["#{callback_url}\n%", "%\n#{callback_url}", "%\n#{callback_url}\n%", callback_url]
      )
    )
  }

  scope :base, lambda {
    find_by(base: true)
  }

  protected

  def clean_allowed_cors
    self.allowed_cors = allowed_cors.to_s.split(/[\r\n]/).map(&:strip).select(&:present?).join("\n")
  end

  def ensure_that_owner_is_mapped_through
    return if !owner || users.include?(owner)
    users.push(owner)
  end
end
