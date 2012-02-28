class Connect::GoogleController < ApplicationController
  before_filter :require_anonymous_access

  def show
    raise AuthenticationRequired.new('Authorization Code Required') unless params[:code]
    authenticate Connect::Google.authenticate(params[:code])
    logged_in!
  end
end
