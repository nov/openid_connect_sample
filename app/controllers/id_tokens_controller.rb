class IdTokensController < ApplicationController
  before_filter :require_id_token

  def show
    render json: @current_token
  end
end
