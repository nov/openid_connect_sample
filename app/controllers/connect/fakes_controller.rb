class Connect::FakesController < ApplicationController
  before_filter :require_anonymous_access

  def create
    authenticate Connect::Fake.authenticate
    logged_in!
  end
end
