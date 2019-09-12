class Connect::FacebookController < ApplicationController
  before_action :require_anonymous_access

  def show
    authenticate Connect::Facebook.authenticate(cookies)
    logged_in!
  end
end
