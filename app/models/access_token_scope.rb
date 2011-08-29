class AccessTokenScope < ActiveRecord::Base
  belongs_to :access_token
  belongs_to :scope

  validates :access_token, presence: true
  validates :scope,        presence: true
end
