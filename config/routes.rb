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
  map.user_activation '/admin/user_activation', :controller => 'admin', :action => 'user_activation'
  map.user_details '/admin/user_details', :controller => 'admin', :action => 'user_details'
  map.set_permissions '/admin/set_permissions', :controller => 'admin', :action => 'set_permissions'
  
  map.root :controller => 'users', :action => 'show'
end
