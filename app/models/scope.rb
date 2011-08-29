class Scope < ActiveRecord::Base
  has_many :access_token_scopes
  has_many :access_tokens, through: :access_token_scopes
  has_many :authorization_scopes
  has_many :authorizations, through: :authorization_scopes

  validates :name, presence: true, uniqueness: true

  include ConstantCache
  caches_constants
end
