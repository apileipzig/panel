ActionController::Routing::Routes.draw do |map|

  map.resource :account, :controller => 'users'
  map.resources :users

  map.resource :user_session
  
  # routes for authentification  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  
  #routes for admins
  map.admin '/admin', :controller => 'admin', :action => 'index' # the admin console
  map.user_details '/admin/user_details', :controller => 'admin', :action => 'user_details'
  map.user_activation '/admin/user_activation', :controller => 'admin', :action => 'user_activation'
  map.user_deactivation '/admin/user_deactivation', :controller => 'admin', :action => 'user_deactivation'
  map.reset_apikey '/admin/reset_apikey', :controller => 'admin', :action => 'reset_apikey'
  map.set_permissions '/admin/set_permissions', :controller => 'admin', :action => 'set_permissions'
  
  map.calendar '/admin/calendar', :controller => 'admin', :action => 'calendar'
  map.create_event '/admin/create_event', :controller => 'admin', :action => 'create_event'
  map.list_events '/admin/list_events', :controller => 'admin', :action => 'list_events'
  
  map.root :controller => 'users', :action => 'show'
end
