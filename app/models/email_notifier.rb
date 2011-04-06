class EmailNotifier < ActionMailer::Base

  def registration_confirmation(user)
    setup_mailer(user.email)
    subject       "API.LEIPZIG - Anmeldung erfolgreich"
    body          :name => user.name
  end
  
  def activation_confirmation(user)
    setup_mailer(user.email)
    subject       "Maiana - Activation Completed"
    body          :root_url => root_url
  end
  
  def password_reset_instructions(user)  
    setup_mailer(user.email)
    subject       "Maiana - Password Reset Instructions"  
    body          :edit_password_reset_url => url_for(:controller => 'password_resets', :action => 'edit', :id => user.perishable_token)  
  end  

  def new_datasource_request(user)
    setup_mailer(user.email)
    subject       "Maiana - Password Reset Instructions"  
    body          :edit_password_reset_url => url_for(:controller => 'password_resets', :action => 'edit', :id => user.perishable_token)  
  end  
  
  protected
  
  def setup_mailer(recipient)
    from          "api.leipzig@tml-consulting.net"
    recipients    recipient
    sent_on       Time.now
  end
  
end
