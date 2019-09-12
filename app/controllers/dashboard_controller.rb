class DashboardController < ApplicationController
  before_action :require_authentication

  def show
    @clients = current_account.clients
  end
end
