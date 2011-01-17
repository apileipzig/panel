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
        user.update_attributes(form_values)
      end
    end
    unless params[:deactivation].blank?
      params[:deactivation].each do |id,form_values|
#        user = User.find(id)
#        user.update_attributes(form_values)
        redirect_to user_details_path(:user => params[:user]) and return
      end
    end    
  end
  
  def user_details
    redirect_to admin_path and return if params[:user].blank?
    @user = User.find(params[:user][:id])
    @user_permissions = @user.permissions
    @permissions = Hash.new
    Permission.all_tables.each do |tablename|
      @permissions[tablename] = {'read', 'write'}
      @permissions[tablename]['read'] = Permission.all.select{|p| p.access == 'read' && p.table == tablename}
      @permissions[tablename]['write'] = Permission.all.select{|p| p.access == 'write' && p.table == tablename}
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
