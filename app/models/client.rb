class Client < ActiveRecord::Base
  [:contacts, :redirect_uris, :raw_registered_json].each do |serializable|
    serialize serializable, JSON
  end

  belongs_to :account
  has_many :access_tokens
  has_many :authorizations

  before_validation :setup, on: :create

  validates :account,    presence: {unless: :dynamic?}
  validates :identifier, presence: true, uniqueness: true
  validates :secret,     presence: true
  validates :name,       presence: true

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

    def register!(registrar)
      registrar.validate!
      client = dynamic.new
      client.attributes = {
        native:            registrar.application_type == 'native',
        ppid:              registrar.subject_type == 'pairwise',
        name:              registrar.client_name,
        jwks_uri:          registrar.jwks_uri,
        sector_identifier: registrar.sector_identifier,
        redirect_uris:     registrar.redirect_uris
      }.delete_if do |key, value|
        value.nil?
      end
      client.raw_registered_json = registrar.as_json
      client.save!
      client
    end
  end

  # for views/clients/_form.html.erb
  attr_accessor :redirect_uri
  def redirect_uri=(redirect_uri)
    self.redirect_uris = Array(redirect_uri)
  end

  def as_json(options = {})
    hash = raw_registered_json || {}
    hash.merge!(
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
    self.name     ||= 'Unknown'
  end
end
