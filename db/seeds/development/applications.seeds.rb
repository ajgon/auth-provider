# frozen_string_literal: true
after 'development:users' do
  app = Application.new(
    name: 'Test App',
    redirect_uri: 'http://localhost:3000/session',
    allowed_cors: 'http://localhost:3000',
    uid: 'def650a40e7df4ae3e4e3cb34d3ff205b8103ec6b86ef8cf3cc33c4f2d4f5108',
    base: false
  )
  app.owner = User.find_by_email('testapp@example.com')
  app.save!
  AuthProvider.create!(application_id: app.id, enabled: true, client_id: app.uid, client_secret: app.secret)
end
