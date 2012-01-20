# -*- encoding : utf-8 -*-
class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages "Benutzername und/oder Passwort ist nicht korrekt."
end
