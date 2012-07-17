class Authorization < ActiveRecord::Base
  belongs_to :account
  belongs_to :client
  has_many :authorization_scopes
  has_many :scopes, through: :authorization_scopes
  has_one :authorization_request_object
  has_one :request_object, through: :authorization_request_object

  before_validation :setup, on: :create

  validates :account,    presence: true
  validates :client,     presence: true
  validates :code,       presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, lambda {
    where { expires_at >= Time.now.utc }
  }

  def expire!
    self.expires_at = Time.now
    self.save!
  end

  def access_token
    @access_token ||= expire! && generate_access_token!
  end

  def valid_redirect_uri?(given_uri)
    given_uri == redirect_uri
  end

  private

  def setup
    self.code       = SecureRandom.hex(32)
    self.expires_at = 5.minutes.from_now
  end

  def generate_access_token!
    token = account.access_tokens.create!(client: client)
    token.scopes << scopes
    token.request_object = request_object
    token
  end
end
