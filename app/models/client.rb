class Client < ActiveRecord::Base
  belongs_to :account
  has_many :access_tokens
  has_many :authorizations

  before_validation :setup, on: :create

  validates :account,      presence: {unless: :dynamic?}
  validates :identifier,   presence: true, uniqueness: true
  validates :secret,       presence: true
  validates :name,         presence: true

  scope :dynamic, where(dynamic: true)
  scope :valid, lambda {
    where {
      (expires_at == nil) |
      (expires_at >= Time.now.utc)
    }
  }

  def self.avairable_response_types
    ['code', 'token', 'id_token', 'code token', 'code id_token', 'id_token token', 'code id_token token']
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
      native:                           registrar.application_type == 'native',
      ppid:                             registrar.user_id_type == 'pairwise',
      name:                             registrar.application_name,
      logo_url:                         registrar.logo_url,
      token_endpoint_auth_type:         registrar.token_endpoint_auth_type,
      policy_url:                       registrar.policy_url,
      jwk_url:                          registrar.jwk_url,
      jwk_encryption_url:               registrar.jwk_encryption_url,
      x509_url:                         registrar.x509_url,
      x509_encryption_url:              registrar.x509_encryption_url,
      sector_identifier:                registrar.sector_identifier,
      require_signed_request_object:    registrar.require_signed_request_object,
      contacts:                         registrar.contacts.try(:join, ' '),
      redirect_uris:                    registrar.redirect_uris.try(:join, ' '),
      userinfo_signed_response_alg:     registrar.userinfo_signed_response_alg,
      userinfo_encrypted_response_alg:  registrar.userinfo_encrypted_response_alg,
      id_token_signed_response_alg:     registrar.id_token_signed_response_alg,
      id_token_encrypted_response_alg:  registrar.id_token_encrypted_response_alg
    }.delete_if do |key, value|
      value.nil?
    end
    client
  end

  [
    :contacts,
    :redirect_uris,
  ].each do |plurar_attribute|
    define_method plurar_attribute do
      value = read_attribute(plurar_attribute)
      value.try(:split, ' ')
    end
  end

  def as_json(options = {})
    hash = {
      client_id: identifier,
      expires_at: expires_at.to_i
    }
    hash[:client_secret] = secret unless native?
    hash
  end

  private

  def setup
    self.identifier = SecureRandom.hex(16)
    self.secret     = SecureRandom.hex(32)
    self.expires_at = 1.hour.from_now if dynamic?
  end
end
