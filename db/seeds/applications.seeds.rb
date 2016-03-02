# frozen_string_literal: true
after 'users' do
  app = Application.new(
    name: 'Auth Provider',
    redirect_uri: Rails.application.routes.url_helpers.session_url(
      ActionMailer::Base.default_url_options.merge(subdomain: :app)
    ),
    base: true
  )
  app.owner = User.find_by_email('admin@example.com')
  app.save!
end
