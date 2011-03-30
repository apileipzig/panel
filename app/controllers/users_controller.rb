class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.active = false
    @user.admin = false
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
    @permissions = Hash.new
    Permission.all_tables.each do |tablename|
      @permissions[tablename] = Hash.new
      %w[create read update delete].each do |access|
        permissions = @user.permissions.select{|p| p.access == access && p.table == tablename}
        unless permissions.blank?
          @permissions[tablename][access] = Hash.new 
          @permissions[tablename][access] = permissions
        end
      end
      @permissions.delete_if{|k,v| v.blank?}
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    params[:user].delete('email') # make sure, the user cannot change its unique login value
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

end
