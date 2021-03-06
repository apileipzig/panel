# -*- encoding : utf-8 -*-
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
      #next unless event['owner_id'] == @current_user.id
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

    # data from previously failed attempts
    @data = params[:event] ||= Hash.new
  end

  def create
    if params.has_key?('commit')
      e = params[:event].delete_if{|k, v| v.blank?}
      unless e.empty?
        e['category_id'] = params[:branch]
        e['time_from'] = e['time_from'] + ":00" if e['time_from']
        e['time_to'] = e['time_to'] + ":00" if e['time_to']
        e['host_id'] = params[:host]
        e['venue_id'] = params[:venue]
        e['owner_id'] = @current_user.id
        e['public'] = e['public'].present? ? true : false
        @result = retrieve_data('post', 'calendar', 'events', "", e)
        if @result.has_key?('success')
          flash[:success] = "Termin gespeichert"
          redirect_to events_path and return
        else
          flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
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
      @result = retrieve_data('get', 'calendar', 'events', @event_id)
      unless @result.has_key?('error')
        unless @result['owner_id'] == @current_user.id
          # User may only edit its own events.
          flash[:error] = "Sie haben keine Berechtigung für diese Seite."
          redirect_to events_path and return
        end
        # get all venues, hosts, and branches for selection
        @venues = retrieve_data('get', 'calendar', 'venues')
        @hosts = retrieve_data('get', 'calendar', 'hosts')
        @branches = retrieve_data('get', 'mediahandbook', 'branches').select{|b| b['internal_type'] == 'sub_market'}
      else
        flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
        redirect_to events_path and return
      end
    else
      flash[:error] = "Sie haben keine Berechtigung für diese Seite."
      redirect_to events_path and return
    end
  end

  def update
    if params.has_key?('commit')
      e = params[:event].delete_if{|k, v| v.blank?}
      unless e.empty?
        e['api_key'] = @current_user.single_access_token
        e['category_id'] = params[:branch]
        e['time_from'] = e['time_from'].split(':').length > 2 ? e['time_from'] : e['time_from'] + ":00" if e['time_from']
        e['time_to'] = e['time_to'].split(':').length > 2 ? e['time_to'] : e['time_to'] + ":00" if e['time_to']
        e['host_id'] = params[:host]
        e['venue_id'] = params[:venue]
        e['owner_id'] = @current_user.id
        e['public'] = e['public'].present? ? true : false
        @result = retrieve_data('put', 'calendar', 'events', params[:event_id], e)
        if @result.has_key?('success')
          flash[:success] = "Termin gespeichert"
          redirect_to events_path and return
        else
          flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
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
    flash[:error] = "Sie haben keine Berechtigung für diese Seite."
    redirect_to events_path and return
  end

  private

  def extract_error_message(error)
    if error.kind_of?(Hash)
      first_error = error.to_a.first
      column = first_error.first
      message = first_error.second.first.gsub(' ', '_').delete(".,'").downcase
      return "#{t("data.calendar.events.#{column}")} #{t("data.api.messages.#{message}")}"
    else
      first_error = error.split('[')
      column = first_error.second.gsub(']', '')
      message = first_error.first.strip.gsub(' ', '_').delete(".,'").downcase
      return "#{t("data.api.messages.#{message}")} #{t("data.calendar.events.#{column}")}"
    end
  end

  def item_permissions(event_permissions)
    @event_rows = event_permissions.select{|p| p.table == 'events'}.map{|p| p.column}
    @host_rows = event_permissions.select{|p| p.table == 'hosts'}.map{|p| p.column}
    @venue_rows = event_permissions.select{|p| p.table == 'venues'}.map{|p| p.column}
  end
end
