# -*- encoding : utf-8 -*-
class HostsController < ApplicationController

  before_filter :require_user
  def index
    prepare_index
  end

  def create
    # try to create the new host
    h = params[:new_host].delete_if{|k, v| v.blank?}
    unless h.empty?
      @result = retrieve_data('post', 'calendar', 'hosts', "", h)
      if @result.has_key?('success')
        flash[:success] = "Der Veranstalter wurde erfolgreich angelegt"
      else
        flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
        prepare_index
        @data = h.delete_if{|k,v| k == 'api_key'}
        render :action => "index" and return
      end
    end
    redirect_to hosts_path and return
  end

  def edit
    if @current_user.may_update_resource?('calendar', 'hosts')
      @host_rows = @current_user.table_permissions('calendar', 'hosts', 'create').map{|p| p.column}
      @host_id = params[:host]
      @result = retrieve_data('get', 'calendar', 'hosts', @host_id)
      if @result.has_key?('error')
        flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
        redirect_to hosts_path and return
      end
    else
      flash[:error] = "Sie haben keine Berechtigung für diese Seite."
      redirect_to hosts_path and return
    end
  end

  def update
    if params.has_key?('commit')
      h = params[:new_host].delete_if{|k, v| v.blank?}
      unless h.empty?
        @result = retrieve_data('put', 'calendar', 'hosts', params[:host_id], h)
        if @result.has_key?('success')
          flash[:success] = "Veranstalter gespeichert"
          redirect_to hosts_path and return
        else
          flash[:error] = "Die API meldet folgenden Fehler: #{extract_error_message(@result['error'])}"
          redirect_to hosts_path and return
        end
      else
        flash[:error] = "Es ist ein Fehler aufgetreten"
        redirect_to hosts_path and return
      end
    else
      flash[:error] = "Es ist ein Fehler aufgetreten"
      redirect_to hosts_path and return
    end
  end

  def delete
    if @current_user.may_delete_resource?('calendar', 'hosts')
      @result = retrieve_data('delete', 'calendar', 'hosts', params[:host])
      if @result.has_key?('success')
        flash[:success] = "Veranstalter erfolgreich gelöscht"
        redirect_to hosts_path and return
      end
    end
    flash[:error] = "Sie haben keine Berechtigung für diese Seite."
    redirect_to hosts_path and return
  end

  private

  def extract_error_message(error)
    if error.kind_of?(Hash)
      first_error = error.to_a.first
      column = first_error.first
      message = first_error.second.first.gsub(' ', '_').delete(".,'").downcase
      return "#{t("data.calendar.hosts.#{column}")} #{t("data.api.messages.#{message}")}"
    else
      first_error = error.split('[') 
      column = first_error.second.gsub(']', '')
      message = first_error.first.strip.gsub(' ', '_').delete(".,'").downcase
      return "#{t("data.api.messages.#{message}")} #{t("data.calendar.hosts.#{column}")}"
    end
  end

  def prepare_index
    @hosts = retrieve_data('get', 'calendar', 'hosts')
    @host_rows = @current_user.table_permissions('calendar', 'hosts', 'create').map{|p| p.column}
    @editor = @current_user.may_update_resource?('calendar', 'hosts')
    @deletor = @current_user.may_delete_resource?('calendar', 'hosts')
  end
end
