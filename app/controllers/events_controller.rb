require 'net/http'

class EventsController < ApplicationController
  before_filter :require_user
  def index
    @branches = retrieve_data('get', 'mediahandbook', 'branches').select{|b| b['internal_type'] == 'sub_market'}
    @venues = retrieve_data('get', 'calendar', 'venues')
    @hosts = retrieve_data('get', 'calendar', 'hosts')
    @events = retrieve_data('get', 'calendar', 'events')

    @rich_events = Array.new
    @events.each do |event|
      e = Hash.new
      e['event'] = event
      e['host'] = @hosts.select{|h| h['id'] == event['host_id']}.first
      e['venue'] = @venues.select{|v| v['id'] == event['venue_id']}.first
      e['branches'] = @branches.select{|b| b['id'] == event['category_id']}.first
      @rich_events << e
    end
    @editor = @current_user.may_update_resource?('calendar', 'events')
    @deletor = @current_user.may_delete_resource?('calendar', 'events')
  end

  def new
    # get all permissions
    @event_permissions = @current_user.source_permissions('calendar', 'create')
    item_permissions(@event_permissions)

    @branches = retrieve_data('get', 'mediahandbook', 'branches').select{|b| b['internal_type'] == 'sub_market'}
    @venues = retrieve_data('get', 'calendar', 'venues')
    @hosts = retrieve_data('get', 'calendar', 'hosts')

    # data from prviously failed attempts
    @data = params[:event] ||= Hash.new
  end

  def create
    if params.has_key?('commit')
      e = params[:event].delete_if{|k, v| v.blank?}
      unless e.empty?
        e['category_id'] = params[:branch]
        e['time_from'] = e['time_from'] + ":00"
        e['time_to'] = e['time_to'] + ":00"
        e['host_id'] = params[:host]
        e['venue_id'] = params[:venue]
        @result = retrieve_data('post', 'calendar', 'events', "", e)
        if @result.has_key?('success')
          flash[:success] = "Termin gespeichert"
          redirect_to events_path and return
        else
          flash[:error] = "Die API meldet folgenden Fehler: #{t("data.calendar.events.#{@result['error'].to_a.first.first}")} #{t("data.api.messages.#{@result['error'].to_a.first.second.gsub(' ', '_')}")}"
          @data = params[:event]
          redirect_to :action => "new", :event => e and return
        end
      else
        flash[:error] = "Es ist ein Fehler aufgetreten"
        @data = params[:event]
        redirect_to :action => "new", :event => e and return
      end
    else
      flash[:error] = "Es ist ein Fehler aufgetreten"
      @data = params[:event]
      redirect_to :action => "new", :event => e and return
    end
  end

  def edit
    if @current_user.may_update_resource?('calendar', 'events')
      @event_permissions = @current_user.source_permissions('calendar', 'update')
      item_permissions(@event_permissions)
      @event_id = params[:event]
      @result = retrieve_data('get', 'calendar', 'events', params[:event])
      unless @result.has_key?('error')
        # get the host
        @host = retrieve_data('get', 'calendar', 'hosts', @result['host_id'])
        # get the venue
        @venue = retrieve_data('get', 'calendar', 'venues', @result['venue_id'])
        @branches = retrieve_data('get', 'mediahandbook', 'branches').select{|b| b['internal_type'] == 'sub_market'}
      else
        flash[:error] = "Die API meldet folgenden Fehler: #{t("data.calendar.events.#{@result['error'].to_a.first.first}")} #{t("data.api.messages.#{@result['error'].to_a.first.second.gsub(' ', '_')}")}"
        redirect_to events_path and return
      end
    else
      flash[:error] = "Berechtigung fehlt!"
      redirect_to events_path and return
    end
  end

  def update
    if params.has_key?('commit')
      e = params[:event].delete_if{|k, v| v.blank?}
      unless e.empty?
        e['api_key'] = @current_user.single_access_token
        e['category_id'] = params[:branch]
        e['time_from'] = e['time_from'].split(':').length > 2 ? e['time_from'] : e['time_from'] + ":00"
        e['time_to'] = e['time_to'].split(':').length > 2 ? e['time_to'] : e['time_to'] + ":00"
        @result = retrieve_data('put', 'calendar', 'events', params[:event_id], e)
        if @result.has_key?('success')
          flash[:success] = "Termin gespeichert"
          redirect_to events_path and return
        else
          flash[:error] = "Die API meldet folgenden Fehler: #{t("data.calendar.events.#{@result['error'].to_a.first.first}")} #{t("data.api.messages.#{@result['error'].to_a.first.second.gsub(' ', '_')}")}"
          redirect_to new_event_path and return
        end
      else
        flash[:error] = "Es ist ein Fehler aufgetreten"
        redirect_to new_event_path and return
      end
    else
      flash[:error] = "Es ist ein Fehler aufgetreten"
      redirect_to new_event_path and return
    end
  end

  def delete
    if @current_user.may_delete_resource?('calendar', 'events')
      @result = retrieve_data('delete', 'calendar', 'events', params[:event])
      if @result.has_key?('success')
        flash[:success] = "Veranstaltung erfolgreich gelöscht"
        redirect_to events_path and return
      end
    end
    flash[:error] = "Berechtigung fehlt!"
    redirect_to events_path and return
  end

  private

  def item_permissions(event_permissions)
    @event_rows = event_permissions.select{|p| p.table == 'events'}.map{|p| p.column}
    @host_rows = event_permissions.select{|p| p.table == 'hosts'}.map{|p| p.column}
    @venue_rows = event_permissions.select{|p| p.table == 'venues'}.map{|p| p.column}
  end
end