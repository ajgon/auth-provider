# frozen_string_literal: true
after 'users' do
  app = Application.new(
    name: 'Auth Provider',
    redirect_uri: Rails.application.routes.url_helpers.user_omniauth_callback_url(
      :auth_provider,
      ActionMailer::Base.default_url_options
    ),
    base: true
  )
  app.owner = User.find_by_email('admin@example.com')
  app.save!
  AuthProvider.create!(application_id: app.id, enabled: true, client_id: app.uid, client_secret: app.secret)
end
