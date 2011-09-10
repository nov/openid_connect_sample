class Connect::FakesController < ApplicationController
  before_filter :require_anonymous_access

  def create
    authenticate Connect::Fake.authenticate
    redirect_to after_logged_in_endpoint
  end
end
