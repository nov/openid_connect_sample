class SessionsController < ApplicationController
  before_action :require_authentication

  def destroy
    unauthenticate!
    redirect_to root_url
  end
end
