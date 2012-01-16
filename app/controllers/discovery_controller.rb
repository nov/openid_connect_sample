class DiscoveryController < ApplicationController
  def show
    case params[:id]
    when 'simple-web-discovery'
      simple_web_discovery
    when 'openid-configuration'
      openid_configuration
    else
      raise HttpError::NotFound
    end
  end

  private

  def simple_web_discovery
    logger.info params[:service]
    if params[:service] == 'http://openid.net/specs/connect/1.0/issuer'
      render json: {
       :locations => [IdToken.config[:issuer]]
      }
    else
      raise HttpError::NotFound
    end
  end

  def openid_configuration
    render json: {
      version: '3.0',
      issuer: IdToken.config[:issuer],
      authorization_endpoint: new_authorization_url,
      token_endpoint: access_tokens_url,
      userinfo_endpoint: user_info_url,
      check_id_endpoint: id_token_url,
      registration_endpoint: connect_client_url,
      scopes_supported: Scope.all.collect(&:name),
      response_types_supported: Client.avairable_response_types,
      user_id_types_supported: ['public', 'pairwise'],
      x509_url: IdToken.config[:x509_url]
      # NOT SUPPORTED YET
      # * refresh_session_endpoint
      # * end_session_endpoint
      # * jwk_document
      # * iso29115_supported
    }
  end
end
