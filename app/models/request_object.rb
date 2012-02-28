class RequestObject < ActiveRecord::Base
  has_one :access_token_request_object
  has_one :access_token, through: :access_token_request_object
  has_one :authorization_request_object
  has_one :authorization, through: :authorization_request_object
end
