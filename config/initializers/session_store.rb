# -*- encoding : utf-8 -*-
# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_leipzig-api-test_session',
  :secret      => 'ed907015807fa9fc146c3f69f1db07bf0246a4dfd58a9d572b12126e13dbbaec391a06c6f64b4226373ae8be240e7a797c919da434b40b92f03b2337a326fa74'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
