class Connect::ClientsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  rescue_from HttpError do |e|
    render json: {error: e.message}, status: e.status
  end

  def create
    @client = find_or_initialize_client
    @client.dynamic_attributes = params
    if @client.save
      render json: @client
    else
      raise HttpError::BadRequest.new(@client.errors.full_messages.to_sentence)
    end
  end

  private

  def find_or_initialize_client
    case params[:type]
    when 'client_associate'
      Client.dynamic.new
    when 'client_update'
      client = Client.dynamic.find_by_identifier! params[:client_id]
      unless client.secret == params[:client_secret]
        raise HttpError::Unauthorized.new('Invalid Client Credentials')
      end
      client
    else
      raise HttpError::BadRequest.new('Invalid Registration Type')
    end
  end
end
