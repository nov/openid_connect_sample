class DiscoveryController < ApplicationController
  # TODO: Move me to gem
  ISSUER_NAMESPACE = 'http://openid.net/specs/connect/1.0/issuer'

  def show
    case params[:id]
    when 'webfinger'
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
      expires: 1.week.from_now,
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
      request_object_signing_alg_values_supported: [:HS256, :HS384, :HS512],
      subject_types_supported: ['public', 'pairwise'],
      id_token_signing_alg_values_supported: [:RS256],
      claims_supported: ['sub', 'iss', 'name', 'email', 'address', 'phone_number'],
      x509_url: IdToken.config[:x509_url],
      jwk_url: IdToken.config[:jwk_url]
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
