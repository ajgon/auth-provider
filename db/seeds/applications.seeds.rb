after 'users' do
  app = Application.new(
    name: 'Auth Provider',
    redirect_uri: 'https://auth.dev',
    base: true
  )
  app.owner = User.find_by_email('admin@example.com')
  app.save!
end
