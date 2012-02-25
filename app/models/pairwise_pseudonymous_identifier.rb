class PairwisePseudonymousIdentifier < ActiveRecord::Base
  belongs_to :account
  belongs_to :client

  before_validation :setup, on: :create

  validates :account,           presence: true
  validates :sector_identifier, presence: true, uniqueness: {scope: :account_id}
  validates :identifier,        presence: true, uniqueness: true

  private

  def setup
    self.identifier = SecureRandom.hex(16)
  end
end
