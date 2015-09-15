after 'development:users' do
  Application.create!(name: 'Test App', user: User.find_by_email('admin@example.com'))
end
