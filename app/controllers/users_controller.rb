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
      flash[:notice] = "Ihr Zugang wurde angelegt und wartet nun auf seine Freischaltung durch einen Admin."
      EmailNotifier.deliver_registration_confirmation(@user)
      redirect_to login_path
    else
      render :action => :new
    end
  end

  def show
    @user = @current_user
    @permissions = Hash.new
    @user.permissions.each do |p|
      @permissions[p.source] = {} unless @permissions[p.source]
      @permissions[p.source][p.table] = {} unless @permissions[p.source][p.table]
      @permissions[p.source][p.table][p.column] = {} unless @permissions[p.source][p.table][p.column]
      @permissions[p.source][p.table][p.column][p.access] = p unless @permissions[p.source][p.table][p.column][p.access]
    end
  end

  def edit
    @user = @current_user
  end

  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    params[:user].delete('email') # make sure, the user cannot change its unique login value
    if @user.update_attributes(params[:user])
      flash[:notice] = "Ihr Zugang wurde aktualisiert"
      redirect_to account_url
    else
      render :action => :edit
    end
  end

end
