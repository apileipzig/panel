ActionController::Routing::Routes.draw do |map|

  map.resource :account, :controller => 'users'
  map.resources :users

  map.resource :user_session
  
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  
  map.admin '/admin', :controller => 'admin', :action => 'index' # the admin console
  map.user_activation '/admin/user_activation', :controller => 'admin', :action => 'user_activation'
  
  map.root :controller => 'users', :action => 'show' # optional, this just sets the root route
end
