class DiscoveryController < ApplicationController
  # TODO: Move me to gem
  ISSUER_NAMESPACE = 'http://openid.net/specs/connect/1.0/issuer'

  def show
    case params[:id]
    when 'host-meta'
      webfinger_discovery
    when 'simple-web-discovery'
      simple_web_discovery
    when 'openid-configuration'
      openid_configuration
    else
      raise HttpError::NotFound
    end
  end

  private

  def webfinger_discovery
    jrd = {
      links: [{
        rel: ISSUER_NAMESPACE,
        href: IdToken.config[:issuer]
      }]
    }
    jrd[:subject] = params[:resource] if params[:resource].present?
    respond_with jrd
  end

  def simple_web_discovery
    logger.info params[:service]
    if params[:service] == ISSUER_NAMESPACE
      respond_with(
        locations: [IdToken.config[:issuer]]
      )
    else
      raise HttpError::NotFound
    end
  end

  def openid_configuration
    respond_with(
      version: '3.0',
      issuer: IdToken.config[:issuer],
      authorization_endpoint: new_authorization_url,
      token_endpoint: access_tokens_url,
      userinfo_endpoint: user_info_url,
      registration_endpoint: connect_client_url,
      scopes_supported: Scope.all.collect(&:name),
      response_types_supported: Client.avairable_response_types,
      request_object_algs_supported: [:HS256, :HS384, :HS512],
      user_id_types_supported: ['public', 'pairwise'],
      id_token_algs_supported: [:RS256],
      x509_url: IdToken.config[:x509_url],
      jwk_url: IdToken.config[:jwk_url]
      # NOT SUPPORTED YET
      # * refresh_session_endpoint
      # * end_session_endpoint
      # * jwk_document
      # * iso29115_supported
    )
  end

  def respond_with(json)
    if params[:intent]
      @json = json
    else
      render json: json
    end
  end
end
