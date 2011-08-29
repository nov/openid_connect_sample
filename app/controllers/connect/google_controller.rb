class Connect::GoogleController < ApplicationController
  before_filter :require_anonymous_access

  def show
    raise AuthenticationRequired.new('Authorization Code Required') unless params[:code]
    authenticate Connect::Google.authenticate(params[:code])
    redirect_to after_logged_in_endpoint
  end
end
