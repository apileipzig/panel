class EmailNotifier < ActionMailer::Base

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
    body          :edit_password_reset_url => url_for(:controller => 'password_resets', :action => 'edit', :id => user.perishable_token)  
  end  

  def new_datasource_request(user)
    setup_mailer(user.email)
    subject       "API.LEIPZIG - Neue Datenquelle angefragt"  
    body          :name => user.name
  end  
  
  protected
  
  def setup_mailer(recipient)
    from          "api.leipzig@tml-consulting.net"
    recipients    recipient
    sent_on       Time.now
  end
  
end
