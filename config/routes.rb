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
  
  map.events '/events', :controller => 'events', :action => 'index'
  map.new_event '/events/new', :controller => 'events', :action => 'new'
  map.create_event '/events/create', :controller => 'events', :action => 'create'
  map.edit_event '/events/edit', :controller => 'events', :action => 'edit'
  map.update_event '/events/update', :controller => 'events', :action => 'update'
  map.delete_event '/events/delete', :controller => 'events', :action => 'delete'
  
  map.root :controller => 'users', :action => 'show'
end
