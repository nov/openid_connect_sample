class IdToken < ActiveRecord::Base
  belongs_to :account
  belongs_to :client

  before_validation :setup, on: :create

  validates :account, presence: true
  validates :client,  presence: true

  scope :valid, lambda {
    where { expires_at >= Time.now.utc }
  }

  def to_response_object(ppid = false)
    user_id = if ppid
      account.pairwise_pseudonymous_identifiers.find_or_create_by_client_id(client_id).identifier
    else
      account.identifier
    end
    OpenIDConnect::ResponseObject::IdToken.new(
      iss: self.class.config[:issuer],
      user_id: user_id,
      aud: client.identifier,
      exp: expires_at.to_i
    )
  end

  private

  def setup
    self.expires_at = 6.hours.from_now
  end

  class << self
    extend ActiveSupport::Memoizable

    def config
      config_path = File.join Rails.root, 'config/connect/id_token'
      config = YAML.load_file(File.join(config_path, 'issuer.yml'))[Rails.env].symbolize_keys
      config[:private_key] = OpenSSL::PKey::RSA.new(
        File.read(File.join(config_path, 'private.crt')),
        'pass-phrase'
      )
      config[:public_key] = OpenSSL::PKey::RSA.new(
        File.read(File.join(config_path, 'public.crt'))
      )
      config
    end
    memoize :config
  end
end