class RequestObject < ActiveRecord::Base
  has_one :access_token_request_object
  has_one :access_token, through: :access_token_request_object
  has_one :authorization_request_object
  has_one :authorization, through: :authorization_request_object
  has_one :id_token_request_object
  has_one :id_token, through: :id_token_request_object

  def to_request_object
    OpenIDConnect::RequestObject.decode(
      jwt_string,
      (access_token || authorization).client.secret
    )
  end
end
