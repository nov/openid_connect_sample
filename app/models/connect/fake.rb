class Connect::Fake < ActiveRecord::Base
  belongs_to :account

  def to_user_info
    {
      name:     'Fake Account',
      email:    'fake@example.com',
      address:  'Shibuya, Tokyo, Japan',
      profile:  'http://example.com/fake',
      locale:   'ja_JP',
      verified: false
    }
  end

  class << self
    def authenticate
      Account.create!(fake: create!)
    end
  end
end
