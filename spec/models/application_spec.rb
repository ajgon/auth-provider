require 'rails_helper'

RSpec.describe Application, type: :model do
  it 'should return base app' do
    expect(Application.base).to eq Application.find_by(base: true)
  end

  it 'should find application basing on callback' do
    app1 = create(:application, :no_owner)
    app2 = create(:application, :no_owner)
    app3 = create(:application, :no_owner)
    app4 = create(:application, :no_owner)
    app5 = create(:application, :no_owner)
    app6 = create(:application, :no_owner)

    app1.update(allowed_cors: 'http://test1.com')
    app2.update(allowed_cors: 'http://test2.com')
    app3.update(allowed_cors: 'http://test3.com')
    app4.update(allowed_cors: 'http://test1.com, http://test2.com')
    app5.update(allowed_cors: 'http://test1.com, http://test2.com, http://test3.com')
    app6.update(allowed_cors: 'http://other-test.com, http://test.com, http://inner-test.com')

    expect(Application.with_allowed_cors('http://test1.co')).to be_empty
    expect(Application.with_allowed_cors('ttp://test1.com')).to be_empty
    expect(Application.with_allowed_cors('http://test2.co')).to be_empty
    expect(Application.with_allowed_cors('ttp://test2.com')).to be_empty
    expect(Application.with_allowed_cors('http://test3.co')).to be_empty
    expect(Application.with_allowed_cors('ttp://test3.com')).to be_empty
    expect(Application.with_allowed_cors('http://test1.com').map(&:id).sort)
      .to eq [app1.id, app4.id, app5.id].sort
    expect(Application.with_allowed_cors('http://test2.com').map(&:id).sort)
      .to eq [app2.id, app4.id, app5.id].sort
    expect(Application.with_allowed_cors('http://test3.com').map(&:id).sort)
      .to eq [app3.id, app5.id].sort
    expect(Application.with_allowed_cors('http://other-test.com').map(&:id)).to eq [app6.id]
    expect(Application.with_allowed_cors('http://test.com').map(&:id)).to eq [app6.id]
    expect(Application.with_allowed_cors('http://inner-test.com').map(&:id)).to eq [app6.id]

    app1.destroy
    app2.destroy
    app3.destroy
    app4.destroy
    app5.destroy
    app6.destroy
  end

  it 'should clean up callback urls' do
    app = create(:application, :no_owner)
    app.update(allowed_cors: ',url,     url, sdf sdsf url, sdf,a, f,')

    expect(app.allowed_cors).to eq 'url, url, sdf sdsf url, sdf, a, f'

    app.destroy
  end

  it 'should add owner to mappings' do
    app = create(:application, :no_owner)
    user = create(:user)
    app.update(owner: user)

    expect(app.users).to eq [user]

    app.destroy
    user.destroy
  end
end
