class ClientsController < ApplicationController
  before_filter :require_authentication

  def new
    @client = context.new
  end

  def create
    @client = context.new params[:client]
    if @client.save
      redirect_to dashboard_url, flash: {
        notice: "Registered #{@client.name}"
      }
    else
      flash[:error] = @client.errors.full_messages.to_sentence
      render :new
    end
  end

  def destroy
    context.find(params[:id]).destroy
    redirect_to dashboard_url
  end

  private

  def context
    current_account.clients
  end
end
