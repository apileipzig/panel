class AdminController < ApplicationController
  before_filter :require_admin
    
  def index
    @inactive_users = User.find(:all, :conditions => [ "active = ?", false ])
  end
  
  def user_activation
    params[:activation].each do |login,form_values|
      user = User.find_by_login(login)
      user.update_attributes(form_values)
    end
  end
end
