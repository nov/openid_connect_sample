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
    when e.object.invalid?(:type)
      :invalid_type
    when e.object.invalid?(:client_id)
      :invalid_client_id
    when e.object.invalid?(:client_secret)
      :invalid_client_secret
    else
      :invalid_configuration_parameter
    end
    render json: {
      error: error,
      error_description: e.message
    }, status: 400
  end

  def create
    registrar = OpenIDConnect::Client::Registrar.new(request.url, params)
    @client = Client.from_registrar registrar
    if @client.save
      render json: @client
    else
      # should be only when redirect_uri is blank
      raise HttpError::BadRequest.new(@client.errors.full_messages.to_sentence)
    end
  end
end
