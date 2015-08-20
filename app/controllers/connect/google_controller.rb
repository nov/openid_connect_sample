class Connect::GoogleController < ApplicationController
  before_filter :require_anonymous_access

  def show
    if params[:code].blank? || session[:state] != params[:state]
      raise AuthenticationRequired.new
    end
    authenticate Connect::Google.authenticate(params[:code])
    logged_in!
  end

  def new
    session[:state] = SecureRandom.hex(32)
    redirect_to Connect::Google.authorization_uri(
      state: session[:state]
    )
  end
end
