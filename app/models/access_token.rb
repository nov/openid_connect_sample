class AccessToken < ActiveRecord::Base
  belongs_to :account
  belongs_to :client
  has_many :access_token_scopes
  has_many :scopes, through: :access_token_scopes
  has_one :access_token_request_object
  has_one :request_object, through: :access_token_request_object

  before_validation :setup, on: :create

  validates :client,     presence: true
  validates :token,      presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :valid, lambda {
    where { expires_at >= Time.now.utc }
  }

  def to_bearer_token
    Rack::OAuth2::AccessToken::Bearer.new(
      access_token: token,
      expires_in: (expires_at - Time.now.utc).to_i
    )
  end

  def accessible?(_scopes_or_claims_ = nil)
    claims = request_object.try(:to_request_object).try(:userinfo)
    Array(_scopes_or_claims_).all? do |_scope_or_claim_|
      case _scope_or_claim_
      when Scope
        scopes.include? _scope_or_claim_
      else
        claims.try(:accessible?, _scope_or_claim_)
      end
    end
  end

  private

  def setup
    self.token      = SecureRandom.hex(32)
    self.expires_at = 24.hours.from_now
  end
end
