class Client < ActiveRecord::Base
  belongs_to :account
  has_many :access_tokens
  has_many :authorizations

  before_validation :setup, on: :create

  validates :account,      presence: {unless: :dynamic?}
  validates :identifier,   presence: true, uniqueness: true
  validates :secret,       presence: true
  validates :redirect_uri, presence: true, format: URI.regexp
  validates :name,         presence: true

  scope :dynamic, where(dynamic: true)
  scope :valid, lambda {
    where {
      (expires_at == nil) |
      (expires_at >= Time.now.utc)
    }
  }

  def self.avairable_response_types
    ['code', 'token', 'id_token', 'code token', 'code id_token', 'id_token token']
  end

  def self.from_registrar(registrar)
    client = case registrar.type
    when 'client_associate'
      dynamic.new
    when 'client_update'
      client = dynamic.find_by_identifier! registrar.client_id
      unless client.secret == registrar.client_secret
        registrar.errors.add :client_secret
      end
      client
    end
    registrar.validate!
    client.attributes = {
      native:            registrar.application_type == 'native',
      name:              registrar.application_name,
      redirect_uri:      registrar.redirect_uris.try(:first),
      contact:           registrar.contacts.try(:first),
      logo_url:          registrar.logo_url,
      jwk_url:           registrar.jwk_url,
      x509_url:          registrar.x509_url,
      sector_identifier: registrar.sector_identifier
    }.delete_if do |key, value|
      value.nil?
    end
    client
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
      (expires_at - Time.now.utc).to_i
    else
      0
    end
  end

  private

  def setup
    self.identifier = SecureRandom.hex(16)
    self.secret     = SecureRandom.hex(32)
    self.expires_at = 1.hour.from_now if dynamic?
  end
end
