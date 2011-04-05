# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'authlogic'

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end

  def require_admin
    unless current_user.admin?
      flash[:notice] = "You are not authorized to access this page"
      redirect_to account_url
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def retrieve_data(verb, source, table, id = "", form_data = {})
    host_address = "http://178.77.99.225/api/v1"
    api_key = @current_user.single_access_token
    http_header = {"User-Agent" => "api.leipzig panel"} 

    case verb
    when "get"
      uri = URI.parse("#{host_address}/#{source}/#{table}#{id.to_s.length > 0 ? "/#{id}" : ""}?api_key=#{api_key}")
      connection = Net::HTTP.new(uri.host, uri.port)
      connection.start do |http|
        req = Net::HTTP::Get.new(uri.request_uri)
        req.initialize_http_header(http_header)
        res = ActiveSupport::JSON.decode(http.request(req).read_body)
        return res if id.to_s.length > 0
        return res['data']
      end
    when "post"
      form_data['api_key'] = api_key
      uri = URI.parse("#{host_address}/#{source}/#{table}")
      connection = Net::HTTP.new(uri.host, uri.port)
      connection.start do |http|
        req = Net::HTTP::Post.new(uri.path)
        req.initialize_http_header(http_header)
        req.set_form_data(form_data)
        return ActiveSupport::JSON.decode(http.request(req).read_body)
      end
    when "put"
      form_data['api_key'] = api_key
      uri = URI.parse("#{host_address}/#{source}/#{table}#{id.to_s.length > 0 ? "/#{id}" : ""}")
      connection = Net::HTTP.new(uri.host, uri.port)
      connection.start do |http|
        req = Net::HTTP::Put.new(uri.path)
        req.initialize_http_header(http_header)
        req.set_form_data(form_data)
        return ActiveSupport::JSON.decode(http.request(req).read_body)
      end
    when "delete"
      uri = URI.parse("#{host_address}/#{source}/#{table}#{id.to_s.length > 0 ? "/#{id}" : ""}?api_key=#{api_key}")
      connection = Net::HTTP.new(uri.host, uri.port)
      connection.start do |http|
        req = Net::HTTP::Delete.new(uri.request_uri)
        req.initialize_http_header(http_header)
        return ActiveSupport::JSON.decode(http.request(req).read_body)
      end
    end
  end
end
