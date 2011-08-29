class UserInfoController < ApplicationController
  before_filter :require_user_access_token

  def show
    render json: current_token.account.to_response_object(current_token)
  end

  private

  def required_scopes
    Scope::OPENID
  end
end
