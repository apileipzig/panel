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
        redirect_to admin_path and return if user.blank? # There's no user with this id
        user.update_attributes(form_values)
      end
    end
    redirect_to admin_path and return
  end

  def user_deactivation
    unless params[:user].blank?
      user = User.find(params[:user][:id])
      redirect_to admin_path and return if user.blank? # There's no user with this id
      redirect_to user_details_path(:user => params[:user]) and return if user == @current_user # Admin may not deactivate self
      user.update_attributes({:active => '0'})
    end
    redirect_to admin_path and return
  end

  def reset_apikey
    unless params[:user].blank?
      user = User.find(params[:user][:id])
      redirect_to admin_path and return if user.blank? # There's no user with this id
      redirect_to user_details_path(:user => params[:user]) and return if user == @current_user # Admin may not change its own key.
      user.reset_single_access_token!
    end
    redirect_to user_details_path(:user => params[:user]) and return
  end
  def user_details
    redirect_to admin_path and return if params[:user].blank?
    @user = User.find(params[:user][:id])
    @user_permissions = @user.permissions
    @permissions = Hash.new
    Permission.all_tables.each do |tablename|
      @permissions[tablename] = {'read', 'write'}
      @permissions[tablename]['read'] = Permission.all.select{|p| p.access == 'read' && p.tabelle == tablename}
      @permissions[tablename]['write'] = Permission.all.select{|p| p.access == 'write' && p.tabelle == tablename}
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
    redirect_to user_details_path(:user => params[:user])
  end
end
