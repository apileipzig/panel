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
    redirect_to user_details_path(:user => params[:user])
  end

  def calendar
    # get all permissions for creation
    @event_permissions = @current_user.calendar_permissions
    @event_rows = @event_permissions.select{|p| p.table == 'events'}.map{|p| p.column}
    @host_rows = @event_permissions.select{|p| p.table == 'hosts'}.map{|p| p.column}
    @venue_rows = @event_permissions.select{|p| p.table == 'venues'}.map{|p| p.column}

    #get all branches
    branch_uri = URI.parse("http://178.77.99.225/api/v1/mediahandbook/branches?api_key=#{@current_user.single_access_token}")
    connection = Net::HTTP.new(branch_uri.host, branch_uri.port)
    connection.start do |http|
      req = Net::HTTP::Get.new("#{branch_uri.path}?#{branch_uri.query}")
      @branches = ActiveSupport::JSON.decode(http.request(req).read_body)['data']
    end

    #get already existing venues
    venue_uri = URI.parse("http://178.77.99.225/api/v1/calendar/venues?api_key=#{@current_user.single_access_token}")
    connection = Net::HTTP.new(venue_uri.host, venue_uri.port)
    connection.start do |http|
      req = Net::HTTP::Get.new("#{venue_uri.path}?#{venue_uri.query}")
      @venues = ActiveSupport::JSON.decode(http.request(req).read_body)['data']
    end

    #get already existing hosts
    host_uri = URI.parse("http://178.77.99.225/api/v1/calendar/hosts?api_key=#{@current_user.single_access_token}")
    connection = Net::HTTP.new(host_uri.host, host_uri.port)
    connection.start do |http|
      req = Net::HTTP::Get.new("#{host_uri.path}?#{host_uri.query}")
      @hosts = ActiveSupport::JSON.decode(http.request(req).read_body)['data']
    end
  end

  def create_event
    if params.has_key?('commit')
      if params[:host] == 'new'
        # try to create the new host
        h = params[:new_host].delete_if{|k, v| v.blank?}
        unless h.empty?
          h['api_key'] = @current_user.single_access_token
          host_uri = URI.parse("http://178.77.99.225/api/v1/calendar/hosts")
          connection = Net::HTTP.new(host_uri.host, host_uri.port)
          connection.start do |http|
            req = Net::HTTP::Post.new(host_uri.path)
            req.set_form_data(h)
            @result = ActiveSupport::JSON.decode(http.request(req).read_body)
          end
          if @result.has_key?('success')
            host_id = @result['success'].split(' ')[4]
          else
            flash[:error] = @result['error'].to_s
            redirect_to calendar_path and return
          end
        end
      else
        host_id = params[:host]
      end
      if params[:venue] == 'new'
        #try to create the new venue
        v = params[:new_venue].delete_if{|k, v| v.blank?}
        unless v.empty?
          v['api_key'] = @current_user.single_access_token
          venue_uri = URI.parse("http://178.77.99.225/api/v1/calendar/venues")
          connection = Net::HTTP.new(venue_uri.host, venue_uri.port)
          connection.start do |http|
            req = Net::HTTP::Post.new(venue_uri.path)
            req.set_form_data(v)
            @result = ActiveSupport::JSON.decode(http.request(req).read_body)
          end
          if @result.has_key?('success')
            venue_id = @result['success'].split(' ')[4]
          else
            flash[:error] = @result['error'].to_s
            redirect_to calendar_path and return
          end
        end
      else
        venue_id = params[:venue]
      end
      e = params[:event].delete_if{|k, v| v.blank?}
      unless e.empty?
        e['api_key'] = @current_user.single_access_token
        e['venue_id'] = venue_id
        e['host_id'] = host_id
        e['category_id'] = params[:branch]
        e['time_from'] = e['time_from'] + ":00"
        e['time_to'] = e['time_to'] + ":00"
        event_uri = URI.parse("http://178.77.99.225/api/v1/calendar/events")
        connection = Net::HTTP.new(event_uri.host, event_uri.port)
        connection.start do |http|
          req = Net::HTTP::Post.new(event_uri.path)
          req.set_form_data(e)
          @result = ActiveSupport::JSON.decode(http.request(req).read_body)
          Rails.logger.info @result.inspect
        end
        if @result.has_key?('success')
          flash[:notice] = "Termin gespeichert"
          redirect_to list_events_path and return
        else
          flash[:error] = @result['error'].to_s
          redirect_to calendar_path and return
        end
      else
        flash[:error] = "Es ist ein Fehler aufgetreten"
        redirect_to calendar_path and return
      end
    end
  end

  def list_events
    events_uri = URI.parse("http://178.77.99.225/api/v1/calendar/events?api_key=#{@current_user.single_access_token}")
    connection = Net::HTTP.new(events_uri.host, events_uri.port)
    connection.start do |http|
      req = Net::HTTP::Get.new("#{events_uri.path}?#{events_uri.query}")
      @events = ActiveSupport::JSON.decode(http.request(req).read_body)['data']
    end
  end
end
