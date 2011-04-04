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
    Permission.all_sources.each do |source|
      @permissions[source] = Hash.new{|k,v| k[v] = Hash.new{|i,j| i[j] = []}}
      all_permissions = @user.permissions.select{|p| p.source == source}
      tables = all_permissions.map{|p| p.table}.uniq
      tables.each do |table|
        permissions = all_permissions.select{|p| p.table == table}
        columns = permissions.map{|p| p.column}.uniq
        columns.each do |column|
          @permissions[source][table][column] = permissions.select{|p| p.column = column}
        end
      end
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
