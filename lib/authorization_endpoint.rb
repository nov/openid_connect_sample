class AuthorizationEndpoint
  attr_accessor :app, :account, :client, :redirect_uri, :response_type, :scopes
  delegate :call, to: :app

  def initialize(current_account, allow_approval = false, approved = false)
    @account = current_account
    @app = Rack::OAuth2::Server::Authorize.new do |req, res|
      @client = Client.find_by_identifier(req.client_id) || req.bad_request!
      res.redirect_uri = @redirect_uri = req.verify_redirect_uri!(@client.redirect_uri)
      @scopes = req.scope.inject([]) do |_scopes_, scope|
        _scopes_ << Scope.find_by_name(scope) or req.invalid_scope! "Unknown scope: #{scope}"
      end
      if Client.avairable_response_types.include? Array(req.response_type).collect(&:to_s).join(' ')
        if allow_approval
          if approved
            approved! req, res
          else
            req.access_denied!
          end
        else
          @response_type = req.response_type
        end
      else
        req.unsupported_response_type!
      end
    end
  end

  def approved!(req, res)
    response_types = Array(req.response_type)
    if response_types.include? :code
      authorization = account.authorizations.create!(client: @client, redirect_uri: res.redirect_uri, nonce: req.nonce)
      authorization.scopes << scopes
      res.code = authorization.code
    end
    if response_types.include? :token
      access_token = account.access_tokens.create!(client: @client)
      access_token.scopes << scopes
      res.access_token = access_token.to_bearer_token
    end
    if response_types.include? :id_token
      res.id_token = account.id_tokens.create!(
        client: @client,
        nonce: req.nonce
      ).to_response_object(
        # TODO
        # scopes.include?(Scope::PPID)
      ).to_jwt IdToken.config[:private_key]
    end
    res.approve!
  end
end