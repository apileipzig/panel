# -*- encoding : utf-8 -*-
class VenuesController < ApplicationController

  before_filter :require_user
  def index
    prepare_index
  end

  def create
    # create the new venue
    v = params[:new_venue].delete_if{|k, v| v.blank?}
    unless v.empty?
      @result = retrieve_data('post', 'calendar', 'venues', "", v)
      if @result.has_key?('success')
        flash[:success] = "Der Veranstalter wurde erfolgreich angelegt"
      else
        flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
        prepare_index
        @data = v.delete_if{|k,v| k == 'api_key'}
        render :action => "index" and return
      end
    end
    redirect_to venues_path and return
  end

  def edit
    if @current_user.may_update_resource?('calendar', 'venues')
      @venue_rows = @current_user.table_permissions('calendar', 'venues', 'create').map{|p| p.column}
      @venue_id = params[:venue]
      @result = retrieve_data('get', 'calendar', 'venues', @venue_id)
      if @result.has_key?('error')
        flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
        redirect_to venues_path and return
      end
    else
      flash[:error] = "Sie haben keine Berechtigung für diese Seite."
      redirect_to venues_path and return
    end
  end

  def update
    if params.has_key?('commit')
      v = params[:new_venue].delete_if{|k, v| v.blank?}
      unless v.empty?
        @result = retrieve_data('put', 'calendar', 'venues', params[:venue_id], v)
        if @result.has_key?('success')
          flash[:success] = "Veranstaltungsort gespeichert"
          redirect_to venues_path and return
        else
          flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
          redirect_to venues_path and return
        end
      else
        flash[:error] = "Es ist ein Fehler aufgetreten"
        redirect_to venues_path and return
      end
    else
      flash[:error] = "Es ist ein Fehler aufgetreten"
      redirect_to venues_path and return
    end
  end

  def delete
    if @current_user.may_delete_resource?('calendar', 'venues')
      @result = retrieve_data('delete', 'calendar', 'venues', params[:venue])
      if @result.has_key?('success')
        flash[:success] = "Veranstaltungsort erfolgreich gelöscht"
        redirect_to venues_path and return
      end
    end
    flash[:error] = "Sie haben keine Berechtigung für diese Seite."
    redirect_to venues_path and return
  end

  private

  def prepare_index
    @venues = retrieve_data('get', 'calendar', 'venues')
    @venue_rows = @current_user.table_permissions('calendar', 'venues', 'create').map{|p| p.column}
    @editor = @current_user.may_update_resource?('calendar', 'venues')
    @deletor = @current_user.may_delete_resource?('calendar', 'venues')
  end
  
  def extract_error_message(error)
    if error.kind_of?(Hash)
      first_error = error.to_a.first
      column = first_error.first
      message = first_error.second.first.gsub(' ', '_').delete(".,'").downcase
      return "#{t("data.calendar.venues.#{column}")} #{t("data.api.messages.#{message}")}"
    else
      first_error = error.split('[') 
      column = first_error.second.gsub(']', '')
      message = first_error.first.strip.gsub(' ', '_').delete(".,'").downcase
      return "#{t("data.api.messages.#{message}")} #{t("data.calendar.venues.#{column}")}"
    end
  end
end
