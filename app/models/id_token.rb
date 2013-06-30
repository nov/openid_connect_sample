class IdToken < ActiveRecord::Base
  belongs_to :account
  belongs_to :client
  has_one :id_token_request_object
  has_one :request_object, through: :id_token_request_object

  before_validation :setup, on: :create

  validates :account, presence: true
  validates :client,  presence: true

  scope :valid, lambda {
    where { expires_at >= Time.now.utc }
  }

  def to_response_object(with = {})
    subject = if client.ppid?
      account.pairwise_pseudonymous_identifiers.find_or_create_by_sector_identifier(client.sector_identifier).identifier
    else
      account.identifier
    end
    claims = {
      iss: self.class.config[:issuer],
      sub: subject,
      aud: client.identifier,
      nonce: nonce,
      exp: expires_at.to_i,
      iat: created_at.to_i
    }
    if accessible?(:auth_time)
      claims[:auth_time] = account.last_logged_in_at.to_i
    end
    if accessible?(:acr)
      required_acr = request_object.to_request_object.id_token.claims[:acr].try(:[], :values)
      if required?(:acr) && required_acr && !required_acr.include?('0')
        # TODO: return error, maybe not this place though.
      end
      claims[:acr] = '0'
    end
    id_token = OpenIDConnect::ResponseObject::IdToken.new(claims)
    id_token.code = with[:code] if with[:code]
    id_token.access_token = with[:access_token] if with[:access_token]
    id_token
  end

  def to_jwt(with = {})
    to_response_object(with).to_jwt self.class.config[:private_key]
  end

  private

  def required?(claim)
    request_object.try(:to_request_object).try(:id_token).try(:required?, claim)
  end

  def accessible?(claim)
    request_object.try(:to_request_object).try(:id_token).try(:accessible?, claim)
  end

  def setup
    self.expires_at = 6.hours.from_now
  end

  class << self
    def decode(id_token)
      OpenIDConnect::ResponseObject::IdToken.decode id_token, config[:public_key]
    rescue => e
      logger.error e.message
      nil
    end

    def config
      unless @config
        config_path = File.join Rails.root, 'config/connect/id_token'
        @config = YAML.load_file(File.join(config_path, 'issuer.yml'))[Rails.env].symbolize_keys
        @config[:jwks_uri] = File.join(@config[:issuer], 'jwks.json')
        private_key = OpenSSL::PKey::RSA.new(
          File.read(File.join(config_path, 'private.key')),
          'pass-phrase'
        )
        cert = OpenSSL::X509::Certificate.new(
          File.read(File.join(config_path, 'cert.pem'))
        )
        @config[:public_key]  = cert.public_key
        @config[:private_key] = private_key
        @config[:jwk_set] = JSON::JWK::Set.new(
          JSON::JWK.new(cert.public_key, use: :sig)
        )
      end
      @config
    end
  end
end