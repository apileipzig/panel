# -*- encoding : utf-8 -*-
class EmailNotifier < ActionMailer::Base
  default_url_options[:host] = "www.apileipzig.de"  
    
  def registration_confirmation(user)
    setup_mailer(user.email)
    subject       "API.LEIPZIG - Anmeldung erfolgreich"
    body          :name => user.name
  end

  def activation_confirmation(user)
    setup_mailer(user.email)
    subject       "API.LEIPZIG - Freischaltung erfolgt"
    body          :name => user.name
  end

  def password_reset_instructions(user)
    setup_mailer(user.email)
    subject       "API.LEIPZIG - Passwort ändern"
    body          :name => user.name, :edit_password_reset_url => edit_password_reset_url(user.perishable_token)
  end

  def new_datasource_request(user)
    setup_mailer(user.email)
    subject       "API.LEIPZIG - Neue Datenquelle angefragt"
    body          :name => user.name
  end

  protected

  def setup_mailer(recipient)
    from          "info@apileipzig.de"
    recipients    recipient
    sent_on       Time.now
  end

end
