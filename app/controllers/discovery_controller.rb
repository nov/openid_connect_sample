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
       :locations => [new_authorization_url]
      }
    else
      raise HttpError::NotFound
    end
  end

  def openid_configuration
    render json: {
      version: '3.0',
      issuer: root_url,
      authorization_endpoint: new_authorization_url,
      token_endpoint: access_tokens_url,
      registration_endpoint: connect_client_url,
      user_info_endpoint: user_info_url,
      check_session_endpoint: id_token_url,
      scopes_supported: Scope.all.collect(&:name),
      flows_supported: Client.avairable_response_types,
      identifiers_supported: ['public', 'ppid']
    }
  end
end
