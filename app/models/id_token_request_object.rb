class IdTokenRequestObject < ActiveRecord::Base
  belongs_to :id_token
  belongs_to :request_object

  validates :id_token,   presence: true
  validates :request_object, presence: true
end
