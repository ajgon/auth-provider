require 'rails_helper'

RSpec.describe Application, type: :model do
  before(:all) do
    @auth_provider = AuthProvider.new
    @facebook = Facebook.new
    @github = Github.new
    @google = GoogleOauth2.new
    @instagram = Instagram.new
    @linkedin = Linkedin.new
    @twitter = Twitter.new
  end

  it 'should return provider name' do
    expect(@auth_provider.name).to eq 'Auth Provider'
    expect(@facebook.name).to eq 'Facebook'
    expect(@github.name).to eq 'GitHub'
    expect(@google.name).to eq 'Google'
    expect(@instagram.name).to eq 'Instagram'
    expect(@linkedin.name).to eq 'Linked in'
    expect(@twitter.name).to eq 'Twitter'
  end

  it 'should return provider slug' do
    expect(@auth_provider.slug).to eq 'auth_provider'
    expect(@facebook.slug).to eq 'facebook'
    expect(@github.slug).to eq 'github'
    expect(@google.slug).to eq 'google_oauth2'
    expect(@instagram.slug).to eq 'instagram'
    expect(@linkedin.slug).to eq 'linkedin'
    expect(@twitter.slug).to eq 'twitter'
  end
end
