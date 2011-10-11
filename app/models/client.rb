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
  scope :valid, lambda {
    where { expires_at == nil || expires_at >= Time.now.utc }
  }

  attr_accessible :redirect_uri, :name, :native, :contact, :logo_url, :js_origin_uri, :jwk_url, :x509_url, :sector_identifier

  def dynamic_attributes=(attributes)
    self.attributes = {
      native:            attributes[:application_type] == 'native',
      name:              attributes[:application_name],
      redirect_uri:      attributes[:redirect_uri],
      contact:           attributes[:contact],
      logo_url:          attributes[:logo_url],
      js_origin_uri:     attributes[:js_origin_uri],
      jwk_url:           attributes[:jwk_url],
      x509_url:          attributes[:x509_url],
      sector_identifier: attributes[:sector_identifier]
    }
  end

  def as_json(options = {})
    hash = {
      client_id: identifier,
      expires_in: expires_in
    }
    hash[:client_secret] = secret unless native?
    hash
  end

  def expires_in
    if expires_at
      expires_at - Time.now.utc
    else
      0
    end
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
    self.expires_at = 1.hour.from_now if dynamic?
  end
end
