class Connect::FakesController < ApplicationController
  before_action :require_anonymous_access

  def create
    authenticate Connect::Fake.authenticate
    logged_in!
  end
end
