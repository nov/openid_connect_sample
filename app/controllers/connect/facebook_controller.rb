class Connect::FacebookController < ApplicationController
  before_filter :require_anonymous_access

  def show
    authenticate Connect::Facebook.authenticate(cookies)
    redirect_to after_logged_in_endpoint
  end
end
