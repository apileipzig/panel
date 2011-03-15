require 'net/http'

class EventsController < ApplicationController
  before_filter :require_user
  
  def index
    @branches = retrieve_data('mediahandbook', 'branches').select{|b| b['internal_type'] == 'sub_market'}
    @venues = retrieve_data('calendar', 'venues')
    @hosts = retrieve_data('calendar', 'hosts')
    @events = retrieve_data('calendar', 'events')

    @rich_events = Array.new
    @events.each do |event|
      e = Hash.new
      e['event'] = event
      e['host'] = @hosts.select{|h| h['id'] == event['host_id']}.first
      e['venue'] = @venues.select{|v| v['id'] == event['venue_id']}.first
      e['branches'] = @branches.select{|b| b['id'] == event['category_id']}.first
      @rich_events << e
    end
    @editor = @current_user.may_update_calendar?
    @deletor = @current_user.may_delete_calendar?
  end

  def new
    # get all permissions for creation
    @event_permissions = @current_user.calendar_create_permissions
    @event_rows = @event_permissions.select{|p| p.table == 'events'}.map{|p| p.column}
    @host_rows = @event_permissions.select{|p| p.table == 'hosts'}.map{|p| p.column}
    @venue_rows = @event_permissions.select{|p| p.table == 'venues'}.map{|p| p.column}

    @branches = retrieve_data('mediahandbook', 'branches').select{|b| b['internal_type'] == 'sub_market'}
    @venues = retrieve_data('calendar', 'venues')
    @hosts = retrieve_data('calendar', 'hosts')
  end

  def create
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
            redirect_to new_event_path and return
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
            redirect_to new_event_path and return
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
          flash[:success] = "Termin gespeichert"
          redirect_to events_path and return
        else
          flash[:error] = @result['error'].to_s
          redirect_to new_event_path and return
        end
      else
        flash[:error] = "Es ist ein Fehler aufgetreten"
        redirect_to new_event_path and return
      end
    end
  end

  def delete
    if @current_user.may_delete_calendar?
      event = params[:event]
      events_uri = URI.parse("http://178.77.99.225/api/v1/calendar/events/#{event}?api_key=#{@current_user.single_access_token}")
      connection = Net::HTTP.new(events_uri.host, events_uri.port)
      connection.start do |http|
        req = Net::HTTP::Delete.new("#{events_uri.path}?#{events_uri.query}")
        @result = ActiveSupport::JSON.decode(http.request(req).read_body)
        if @result.has_key?('success')
          flash[:success] = "Veranstaltung erfolgreich gelöscht"
          redirect_to events_path and return
        end
      end
      Rails.logger.info @result.inspect
    end
    flash[:error] = "Berechtigung fehlt!"
    redirect_to events_path and return
  end

  private

  def retrieve_data(source, table)
    uri = URI.parse("http://178.77.99.225/api/v1/#{source}/#{table}?api_key=#{@current_user.single_access_token}")
    connection = Net::HTTP.new(uri.host, uri.port)
    connection.start do |http|
      req = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")
      return ActiveSupport::JSON.decode(http.request(req).read_body)['data']
    end
  end

end