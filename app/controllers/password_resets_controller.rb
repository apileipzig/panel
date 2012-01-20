# -*- encoding : utf-8 -*-
class PasswordResetsController < ApplicationController
  before_filter :require_no_user
  before_filter :load_user_using_perishable_token, :only => [ :edit, :update ]

  def new
    render
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = "Sie haben eine Anleitung zum Ändern Ihres Passworts per E-Mail erhalten."
      redirect_to root_url
    else
      flash[:error] = "Diese E-Mail-Adresse ist uns nicht bekannt"
      render :action => :new
    end
  end

  def edit
    render
  end

  def update
    @user.password = params[:password]
    @user.password_confirmation = params[:password]
    if @user.save
      flash[:success] = "Ihr Passwort wurde aktualisiert."
      redirect_to account_url
    else
      render :action => :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = "Entschuldigung, aber dieser Account existiert nicht."
      redirect_to root_url
    end
  end
end
