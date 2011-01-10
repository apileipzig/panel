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
end
