# -*- encoding : utf-8 -*-
require 'net/http'

class AdminController < ApplicationController
  before_filter :require_user, :require_admin
  def index
    @users = User.find(:all, :order => 'created_at DESC')
    @stats_tables = []
    data_points = {'data' => []}
    RequestLog.table_stats.each do |stat|
      @stats_tables << stat['name']
      data_points['data'] << stat['data']
    end
    @stats_data = [data_points]
  end

  def user_activation
    redirect_to admin_path and return if params[:user].blank?
    user = User.find(params[:user])
    if user.blank?
      flash[:error] = "Dieser Benutzer existiert nicht"
      redirect_to admin_path and return
    end
    if user == @current_user && user.active?
      flash[:error] = "Sie können sich nicht selbst deaktivieren."
      redirect_to admin_path and return
    end
    new_status = user.active? ? '0' : '1'
    user.update_attributes({:active => new_status})
    if user.active?
      EmailNotifier.deliver_activation_confirmation(user) 
      flash[:success] = "Der Benutzer wurde erfolgreich aktiviert. Ihm wurde automatisch eine E-Mail-Benachrichtigung zugestellt."
      user.initialize_permissions
    end
    flash[:success] = "Der Benutzer wurde erfolgreich deaktiviert." unless user.active?
    redirect_to admin_path and return
  end

  def set_admin
    unless params[:user].blank?
      user = User.find(params[:user])
      if user.blank?
        flash[:error] = "Dieser Benutzer existiert nicht"
        redirect_to admin_path and return  # There's no user with this id
      end
      new_status = user.admin? ? '0' : '1'
      user.update_attributes({:admin => new_status})
    end
    flash[:success] = "Der Benutzer wurde erfolgreich aktiviert. Ihm wurde automatisch eine E-Mail-Benachrichtigung zugestellt."
    redirect_to admin_path and return
  end

  def reset_apikey
    unless params[:user].blank?
      user = User.find(params[:user][:id])
      if user.blank?
        flash[:error] = "Dieser Benutzer existiert nicht"
        redirect_to admin_path and return  # There's no user with this id
      end
      if user == @current_user
        flash[:error] = "Ein Admin kann seinen eigenen Schlüssel nicht ändern."
        redirect_to user_details_path(:user => params[:user][:id]) and return if user == @current_user # Admin may not change its own key.
      end
      user.reset_single_access_token!
    end
    flash[:success] = "Der API-Key wurde zurückgesetzt."
    redirect_to user_details_path(:user => params[:user][:id]) and return
  end

  def user_details
    redirect_to admin_path and return if params[:user].blank?
    @user = User.find(params[:user])
    @user_permissions = @user.permissions
    @permissions = {}
    Permission.all.each do |p|
      @permissions[p.source] = {} unless @permissions[p.source]
      @permissions[p.source][p.table] = {} unless @permissions[p.source][p.table]
      @permissions[p.source][p.table][p.column] = {} unless @permissions[p.source][p.table][p.column]
      @permissions[p.source][p.table][p.column][p.access] = p.id unless @permissions[p.source][p.table][p.column][p.access]
    end
  end

  def delete_user
    redirect_to admin_path and return if params[:user].blank?
    user = User.find(params[:user])
    if user == @current_user
      flash[:error] = "Sie können sich nicht selbst löschen."
      redirect_to admin_path and return
    end
    user.destroy
    flash[:success] = "Der Benutzer wurde erfolgreich gelöscht."
    redirect_to admin_path and return
  end

  def set_permissions
    redirect_to admin_path and return if params[:user].blank?
    @user = User.find(params[:user][:id])
    @updated_permissions = []
    unless params[:permissions].nil?
      params[:permissions].each do |id, value|
        @updated_permissions << Permission.find(id)
      end
    end
    #delete all elements from @user.permissions which are not in @updated_permissions
    #and merge all new elements from @updated_permissions to @user.permissions
    @user.permissions = @user.permissions & @updated_permissions | @updated_permissions

    flash[:success] = "Die Rechte wurden geändert."
    redirect_to user_details_path(:user => params[:user][:id])
  end
end
