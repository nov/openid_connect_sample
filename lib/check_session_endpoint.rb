class CheckSessionEndpoint
  attr_accessor :app
  delegate :call, to: :app

  def initialize
    @app = OpenIDConnect::Server::IdToken.new do |req, res|
      authenticator req, res
    end
  end

  def authenticator(req, res)
    id_token = OpenIDConnect::ResponseObject::IdToken.from_jwt req.id_token, IdToken.config[:public_key]
    client = Client.find_by_identifier! id_token.aud
    id_token.verify! client.identifier
    res.id_token = id_token
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError, AttrRequired::AttrMissing, OpenIDConnect::ResponseObject::IdToken::InvalidToken => e
    req.invalid_id_token! e.message
  end
end