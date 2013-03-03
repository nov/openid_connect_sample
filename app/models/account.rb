class Account < ActiveRecord::Base
  has_one :facebook, class_name: 'Connect::Facebook'
  has_one :google,   class_name: 'Connect::Google'
  has_one :fake,     class_name: 'Connect::Fake'
  has_many :clients
  has_many :access_tokens
  has_many :authorizations
  has_many :id_tokens
  has_many :pairwise_pseudonymous_identifiers

  before_validation :setup, on: :create

  validates :identifier, presence: true, uniqueness: true

  def to_response_object(access_token)
    user_info = (google || facebook || fake).user_info
    unless access_token.accessible?(Scope::PROFILE)
      user_info.all_attributes.each do |attribute|
        user_info.send("#{attribute}=", nil) unless access_token.accessible?(attribute)
      end
    end
    user_info.email        = nil unless access_token.accessible?(Scope::EMAIL)   || access_token.accessible?(:email)
    user_info.address      = nil unless access_token.accessible?(Scope::ADDRESS) || access_token.accessible?(:address)
    user_info.phone_number = nil unless access_token.accessible?(Scope::PHONE)   || access_token.accessible?(:phone)
    user_info.subject = if access_token.client.ppid?
      PairwisePseudonymousIdentifier.find_or_create_by_sector_identifier(access_token.client.sector_identifier).identifier
    else
      identifier
    end
    user_info
  end

  private

  def setup
    self.identifier = SecureRandom.hex(8)
  end
end