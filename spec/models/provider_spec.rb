# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Provider, type: :model do
  let(:auth_provider) { AuthProvider.new }
  let(:facebook) { Facebook.new }
  let(:github) { Github.new }
  let(:google) { GoogleOauth2.new }
  let(:instagram) { Instagram.new }
  let(:linkedin) { Linkedin.new }
  let(:twitter) { Twitter.new }

  it 'returns provider name' do
    expect(auth_provider.name).to eq 'Auth Provider'
    expect(facebook.name).to eq 'Facebook'
    expect(github.name).to eq 'GitHub'
    expect(google.name).to eq 'Google'
    expect(instagram.name).to eq 'Instagram'
    expect(linkedin.name).to eq 'Linked in'
    expect(twitter.name).to eq 'Twitter'
  end

  it 'returns provider slug' do
    expect(auth_provider.slug).to eq 'auth_provider'
    expect(facebook.slug).to eq 'facebook'
    expect(github.slug).to eq 'github'
    expect(google.slug).to eq 'google_oauth2'
    expect(instagram.slug).to eq 'instagram'
    expect(linkedin.slug).to eq 'linkedin'
    expect(twitter.slug).to eq 'twitter'
  end
end
