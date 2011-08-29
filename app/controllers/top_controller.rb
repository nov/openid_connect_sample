class TopController < ApplicationController
  before_filter :require_anonymous_access

  def index
  end
end
