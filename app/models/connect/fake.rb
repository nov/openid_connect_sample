class Connect::Fake < ActiveRecord::Base
  belongs_to :account

  def userinfo
    OpenIDConnect::ResponseObject::UserInfo.new(
      name:         'Fake Account',
      email:        'fake@example.com',
      address:      'Shibuya, Tokyo, Japan',
      profile:      'http://example.com/fake',
      locale:       'ja_JP',
      phone_number: '+81 (3) 1234 5678',
      verified: false
    )
  end

  class << self
    def authenticate
      Account.create!(fake: create!)
    end
  end
end
