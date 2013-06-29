class Connect::ClientsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  rescue_from HttpError do |e|
    render json: {
      error: :invalid_request,
      error_description: e.message
    }, status: 400
  end
  rescue_from OpenIDConnect::ValidationFailed do |e|
    logger.info e.object
    error = case
    when e.object.invalid?(:redirect_uris)
      :redirect_uris
    else
      :invalid_configuration_parameter
    end
    render json: {
      error: :invalid_client_metadata,
      error_description: e.message
    }, status: 400
  end

  def create
    registrar = OpenIDConnect::Client::Registrar.new(request.url, params)
    client = Client.register! registrar
    render json: client
  end
end
