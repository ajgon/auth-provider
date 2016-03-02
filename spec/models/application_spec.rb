# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Application, type: :model do
  it 'returns base app' do
    expect(described_class.base).to eq described_class.find_by(base: true)
  end

  it 'finds application basing on callback' do
    app1 = create(:application, :no_owner)
    app2 = create(:application, :no_owner)
    app3 = create(:application, :no_owner)
    app4 = create(:application, :no_owner)
    app5 = create(:application, :no_owner)
    app6 = create(:application, :no_owner)

    app1.update(allowed_cors: 'http://test1.com')
    app2.update(allowed_cors: 'http://test2.com')
    app3.update(allowed_cors: 'http://test3.com')
    app4.update(allowed_cors: "http://test1.com\nhttp://test2.com")
    app5.update(allowed_cors: "http://test1.com\nhttp://test2.com\nhttp://test3.com")
    app6.update(allowed_cors: "http://other-test.com\nhttp://test.com\nhttp://inner-test.com")

    expect(described_class.with_allowed_cors('http://test1.co')).to be_empty
    expect(described_class.with_allowed_cors('ttp://test1.com')).to be_empty
    expect(described_class.with_allowed_cors('http://test2.co')).to be_empty
    expect(described_class.with_allowed_cors('ttp://test2.com')).to be_empty
    expect(described_class.with_allowed_cors('http://test3.co')).to be_empty
    expect(described_class.with_allowed_cors('ttp://test3.com')).to be_empty
    expect(described_class.with_allowed_cors('http://test1.com').map(&:id).sort)
      .to eq [app1.id, app4.id, app5.id].sort
    expect(described_class.with_allowed_cors('http://test2.com').map(&:id).sort)
      .to eq [app2.id, app4.id, app5.id].sort
    expect(described_class.with_allowed_cors('http://test3.com').map(&:id).sort)
      .to eq [app3.id, app5.id].sort
    expect(described_class.with_allowed_cors('http://other-test.com').map(&:id)).to eq [app6.id]
    expect(described_class.with_allowed_cors('http://test.com').map(&:id)).to eq [app6.id]
    expect(described_class.with_allowed_cors('http://inner-test.com').map(&:id)).to eq [app6.id]

    app1.destroy
    app2.destroy
    app3.destroy
    app4.destroy
    app5.destroy
    app6.destroy
  end

  it 'adds AuthProvider by default' do
    app = create(:application, :no_owner)

    expect(app.providers.size).to eq 1
    expect(app.providers.first.type).to eq 'AuthProvider'
    expect(app.providers.first.enabled).to be_truthy
    expect(app.providers.first.client_id).to eq app.uid
    expect(app.providers.first.client_secret).to eq app.secret
  end

  it 'returns external providers' do
    provider = create(:provider, :facebook)
    provider.reload

    expect(provider.applications.first.providers.size).to eq 2
    expect(provider.applications.first.providers.map(&:type).sort).to eq %w(AuthProvider Facebook)
    expect(provider.applications.first.external_providers.size).to eq 1
    expect(provider.applications.first.external_providers.map(&:type).sort).to eq %w(Facebook)
  end

  it 'cleans up callback urls' do
    app = create(:application, :no_owner)
    app.update(allowed_cors: "\nurl\n\r     url\r sdf sdsf url\r\n sdf\na\n f\n")

    expect(app.allowed_cors).to eq "url\nurl\nsdf sdsf url\nsdf\na\nf"

    app.destroy
  end

  it 'adds owner to mappings' do
    app = create(:application, :no_owner)
    user = create(:user)
    app.update(owner: user)

    expect(app.users).to eq [user]

    app.destroy
    user.destroy
  end
end
