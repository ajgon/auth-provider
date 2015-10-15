after 'users' do
  app = Application.new(
    name: 'Auth Provider',
    redirect_uri: 'http://auth.dev/authprovider/callback',
    base: true
  )
  app.owner = User.find_by_email('admin@example.com')
  app.save!
end
