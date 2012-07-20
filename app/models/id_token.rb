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

  def to_response_object
    user_id = if client.ppid?
      account.pairwise_pseudonymous_identifiers.find_or_create_by_sector_identifier(client.sector_identifier).identifier
    else
      account.identifier
    end
    claims = {
      iss: self.class.config[:issuer],
      user_id: user_id,
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
    OpenIDConnect::ResponseObject::IdToken.new(claims)
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
        @config[:x509_url] = File.join(@config[:issuer], 'cert.pem')
        @config[:jwk_url]  = File.join(@config[:issuer], 'cert.jwk')
        private_key = OpenSSL::PKey::RSA.new(
          File.read(File.join(config_path, 'private.key')),
          'pass-phrase'
        )
        cert = OpenSSL::X509::Certificate.new(
          File.read(File.join(config_path, 'cert.pem'))
        )
        @config[:cert]        = cert
        @config[:public_key]  = cert.public_key
        @config[:private_key] = private_key
        @config[:jwk] = {
          keys: [
            {
              alg: :RSA,
              exp: :AQAB,
              kid: '2012-07-20',
              mod: cert.public_key.to_pem.gsub("\n", '').scan(/KEY-----(.*)-----END/).first.first
            }
          ]
        }
      end
      @config
    end
  end
end