class Client < ActiveRecord::Base
  belongs_to :account
  has_many :access_tokens
  has_many :authorizations

  before_validation :setup, on: :create

  validates :account,      presence: {unless: :dynamic?}
  validates :identifier,   presence: true, uniqueness: true
  validates :secret,       presence: true
  validates :redirect_uri, presence: true, url: true
  validates :name,         presence: true

  scope :dynamic, where(dynamic: true)

  attr_accessible :redirect_uri, :name

  def as_json(options = {})
    {
      client_id: identifier,
      client_secret: secret,
      redirect_uri: redirect_uri,
      name: name,
      expires_in: 0
    }
  end

  def self.metadata
    {
      redirect_uri: {
        type: :uri,
        required: true
      },
      name: {
        type: :string,
        required: true
      }
    }
  end

  def self.avairable_response_types
    ['code', 'token', 'id_token', 'code token', 'code id_token', 'id_token token']
  end

  private

  def setup
    self.identifier = SecureRandom.hex(16)
    self.secret     = SecureRandom.hex(32)
  end
end
