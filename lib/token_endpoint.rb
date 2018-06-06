class TokenEndpoint
  attr_accessor :app
  delegate :call, to: :app

  def initialize
    @app = Rack::OAuth2::Server::Token.new do |req, res|
      client = Client.find_by_identifier(req.client_id) || req.invalid_client!
      client.secret == req.client_secret || req.invalid_client!
      case req.grant_type
      when :client_credentials
        res.access_token = client.access_tokens.create!.to_bearer_token
      when :authorization_code
        authorization = client.authorizations.valid.find_by_code(req.code)
        req.invalid_grant! if authorization.blank? || !authorization.valid_redirect_uri?(req.redirect_uri)
        access_token = authorization.access_token
        res.access_token = access_token.to_bearer_token
        if access_token.accessible?(Scope::OPENID)
          res.id_token = access_token.account.id_tokens.create!(
            client: access_token.client,
            nonce: authorization.nonce,
            request_object: authorization.request_object
          ).to_jwt
        end
      else
        req.unsupported_grant_type!
      end
    end
  end
end

module Rack
  module OAuth2
    class AccessToken
      class Bearer < AccessToken
        def token_response(options = {})
          response = super
          response[:token_type] = 'Bearer' # NOTE: ALB OIDC gateway currently cannot accept "bearer".
          Rails.logger.info(response)
          response
        end
      end
    end
  end
end
