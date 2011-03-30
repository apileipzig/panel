require 'net/http'

class AdminController < ApplicationController
  before_filter :require_admin
  def index
    @inactive_users = User.find(:all, :conditions => [ "active = ?", false ])
    @active_users = User.find(:all, :conditions => [ "active = ?", true])
  end

  def user_activation
    unless params[:activation].blank?
      params[:activation].each do |id,form_values|
        user = User.find(id)
        if user.blank?
          flash[:error] = "Dieser Benutzer existiert nicht"
          redirect_to admin_path and return  # There's no user with this id
        end
        user.update_attributes(form_values)
      end
    end
    flash[:success] = "Der/Die Benutzer wurde/n aktiviert."
    redirect_to admin_path and return
  end

  def user_deactivation
    unless params[:user].blank?
      user = User.find(params[:user][:id])
      if user.blank?
        flash[:error] = "Dieser Benutzer existiert nicht"
        redirect_to admin_path and return  # There's no user with this id
      end
      if user == @current_user
        flash[:error] = "Ein Admin kann sich nicht selbst deaktivieren."
        redirect_to user_details_path(:user => params[:user]) and return if user == @current_user # Admin may not change its own key.
      end
      user.update_attributes({:active => '0'})
    end
    flash[:success] = "Der Benutzer wurde deaktiviert."
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
        redirect_to user_details_path(:user => params[:user]) and return if user == @current_user # Admin may not change its own key.
      end
      user.reset_single_access_token!
    end
    flash[:success] = "Der API-Key wurde zurückgesetzt."
    redirect_to user_details_path(:user => params[:user]) and return
  end

  def user_details
    redirect_to admin_path and return if params[:user].blank?
    @user = User.find(params[:user][:id])
    @user_permissions = @user.permissions
    @permissions = Hash.new
    Permission.all_tables.each do |tablename|
      @permissions[tablename] = Hash.new
      %w[create read update delete].each do |access|
        permissions = Permission.all.select{|p| p.access == access && p.table == tablename}
        unless permissions.blank?
          @permissions[tablename][access] = Hash.new
          @permissions[tablename][access] = permissions
        end
      end
    end
  end

  def set_permissions
    redirect_to user_details_path and return if params[:permission].blank? || params[:user].blank?
    @user = User.find(params[:user][:id])
    params[:permission].each do |id, value|
      if value == '1'
        @user.permissions << Permission.find(id)
      elsif value == '0'
        @user.permissions.delete(Permission.find(id))
      end
    end
    flash[:success] = "Die Rechte wurden geändert."
    redirect_to user_details_path(:user => params[:user])
  end
end
