class Connect::FacebookController < ApplicationController
  before_filter :require_anonymous_access

  def show
    authenticate Connect::Facebook.authenticate(cookies)
    logged_in!
  end
end
