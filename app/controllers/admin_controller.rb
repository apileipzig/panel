class AdminController < ApplicationController
  
  def index
    @inactive_users = User.find(:all, :conditions => [ "active = ?", false ])
  end
end
