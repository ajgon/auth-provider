after 'development:users' do
  app = Application.new(
    name: 'Test App',
    redirect_uri: 'https://test-app.auth.dev',
    base: false
  )
  app.owner = User.find_by_email('testapp@example.com')
  app.save!
end
