class Connect::ClientsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :require_client_access_token, except: [:new, :create]

  def show
    render json: current_token.client
  end

  def new
    render json: Client.metadata
  end

  def create
    @client = Client.dynamic.new params[:client]
    with_validation do
      @client.save
    end
  end

  def update
    @client = current_token.client
    with_validation do
      @client.update_attributes params[:client]
    end
  end

  def destroy
    current_token.client.destroy
    render json: {removed: true}
  end

  private

  def with_validation
    if yield
      render json: @client
    else
      render json: {error: @client.errors, metadata: new_connect_client_url}, status: 400
    end
  end
end
