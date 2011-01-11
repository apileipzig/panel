class AdminController < ApplicationController
  before_filter :require_admin
    
  def index
    @inactive_users = User.find(:all, :conditions => [ "active = ?", false ])
  end
  
  def user_activation
    params[:activation].each do |id,form_values|
      user = User.find(id)
      user.update_attributes(form_values)
    end
  end
  
  def permissions
    @users = User.find(:all, :conditions => [ "active = ? AND admin = ?", true, false ])
    @permissions = Hash.new
    Permission.all_tables.each do |tablename|
      @permissions[tablename] = {'read', 'write'}
      @permissions[tablename]['read'] = Permission.all.select{|p| p.access == 'read' && p.table == tablename}
      @permissions[tablename]['write'] = Permission.all.select{|p| p.access == 'write' && p.table == tablename}
    end
  end
  
  def set_permissions
    redirect_to permissions_path
  end
end
