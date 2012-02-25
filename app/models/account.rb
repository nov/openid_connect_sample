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
        user_info.send "#{attribute}=", nil
      end
    end
    user_info.email        = nil unless access_token.accessible?(Scope::EMAIL)
    user_info.address      = nil unless access_token.accessible?(Scope::ADDRESS)
    user_info.phone_number = nil unless access_token.accessible?(Scope::PHONE)
    user_info.user_id = if false # access_token.accessible?(Scope::PPID)
      # TODO:
      #  Needs update following latest spec.
      #  PPID is per client setting now.
      pairwise_pseudonymous_identifiers.find_or_create_by_client_id(access_token.client_id).identifier
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