class TopController < ApplicationController
  before_action :require_anonymous_access

  def index
  end
end
