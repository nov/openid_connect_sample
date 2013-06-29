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

  class << self
    def available_response_types
      ['code', 'token', 'id_token', 'code token', 'code id_token', 'id_token token', 'code id_token token']
    end

    def available_grant_types
      ['authorization_code', 'implicit']
    end

    def from_registrar(registrar)
      client = case registrar.operation
      when 'client_register'
        dynamic.new
      when 'client_update', 'rotate_secret'
        client = dynamic.find_by_identifier! registrar.client_id
        unless client.secret == registrar.client_secret
          registrar.errors.add :client_secret
        end
        client
      end
      registrar.validate!
      if registrar.operation == 'rotate_secret'
        client.secret = SecureRandom.hex(32)
      else
        client.attributes = {
          native:                          registrar.application_type == 'native',
          ppid:                            registrar.subject_type == 'pairwise',
          name:                            registrar.client_name,
          logo_url:                        registrar.logo_url,
          token_endpoint_auth_method:      registrar.token_endpoint_auth_method,
          policy_url:                      registrar.policy_url,
          jwks_uri:                        registrar.jwks_uri,
          sector_identifier:               registrar.sector_identifier,
          request_object_signing_alg:      registrar.request_object_signing_alg,
          contacts:                        registrar.contacts.try(:join, ' '),
          redirect_uris:                   registrar.redirect_uris.try(:join, ' '),
          userinfo_signed_response_alg:    registrar.userinfo_signed_response_alg,
          userinfo_encrypted_response_alg: registrar.userinfo_encrypted_response_alg,
          id_token_signed_response_alg:    registrar.id_token_signed_response_alg,
          id_token_encrypted_response_alg: registrar.id_token_encrypted_response_alg
        }.delete_if do |key, value|
          value.nil?
        end
        client.registered_json = registrar.as_json
      end
      client
    end
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

  def registered_json
    JSON.parse raw_registered_json
  end

  def registered_json=(hash)
    hash.delete :operation
    self.raw_registered_json = hash.to_json
  end

  def as_json(options = {})
    hash = registered_json.merge(
      client_id: identifier,
      expires_at: expires_at.to_i,
      registration_access_token: 'fake'
    )
    hash[:client_secret] = secret unless native?
    hash
  end

  private

  def setup
    self.identifier = SecureRandom.hex(16)
    self.secret     = SecureRandom.hex(32)
    self.expires_at = 1.hour.from_now if dynamic?
    self.name       ||= 'Unknown'
  end
end
