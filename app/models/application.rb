class Application < Doorkeeper::Application
  has_many :providers

  acts_as_url :name, url_attribute: :slug, blacklist: %w(app new www dev staging admin)
  alias_method :to_param, :slug

  before_save :clean_allowed_cors

  scope :with_allowed_cors, lambda { |callback_url|
    where(
      arel_table[:allowed_cors].matches_any(
        ["#{callback_url},%", "%, #{callback_url}", "%, #{callback_url},%", callback_url]
      )
    )
  }

  scope :base, lambda {
    find_by(base: true)
  }

  protected

  def clean_allowed_cors
    self.allowed_cors = allowed_cors.to_s.split(',').map(&:strip).select(&:present?).join(', ')
  end
end
