class AuthorizationRequestObject < ActiveRecord::Base
  belongs_to :authorization
  belongs_to :request_object

  validates :authorization,  presence: true
  validates :request_object, presence: true
end
