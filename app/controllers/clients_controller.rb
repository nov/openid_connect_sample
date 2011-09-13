class ClientsController < ApplicationController
  before_filter :require_authentication

  def new
    @client = current_account.clients.new
  end

  def create
    @client = current_account.clients.new params[:client]
    if @client.save
      redirect_to dashboard_url, flash: {
        notice: "Registered #{@client.name}"
      }
    else
      flash[:error] = @client.errors.full_messages.to_sentence
      render :new
    end
  end

  def edit
    @client = current_account.clients.find(params[:id])
  end

  def update
    @client = current_account.clients.find(params[:id])
    if @client.update_attributes(params[:client])
      redirect_to dashboard_url, flash: {
        notice: "Updated #{@client.name}"
      }
    else
      flash[:error] = @client.errors.full_messages.to_sentence
      render :edit
    end
  end

  def destroy
    current_account.clients.find(params[:id]).destroy
    redirect_to dashboard_url
  end
end
