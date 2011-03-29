require 'nokogiri'

marker_header = '<!-- /#Start_Content_Marker - DO NOT (RE)MOVE! -->'
marker_footer = '<!-- /#End_Content_Marker - DO NOT (RE)MOVE! -->'

begin
	html = File.open(Rails.root + '../index.html', 'r') { |f| f.read }

  doc = Nokogiri::HTML(html[0,html.index(marker_header)])

  #give body a class
  doc.search('body').each do |e|
    e['class'] = "panel"
  end

  #change yellow button to this
  doc.search('section[@id="SignUp"]/a').each do |e|
    e['href'] = "/panel/"
    e.content = "Mitgliederbereich"
  end

  header = doc.to_s

  #add greeting to the template
  greeter = "<section id=\"user\" class=\"span-4\">\n- if @current_user\n\tHallo,\n\t%a{:href => '#profiledit', :title => 'Nutzer-Profil editieren'}\n\t= @current_user.name\n"
  header.gsub!('<section id="user" class="span-4">',greeter)
  
  #add login/logout switch to the template string
  login_switch = "\n- if @current_user\n\t%a.LogoutLink.span-1.last{:href => logout_path, :title => 'Login'} Logout \n- else\n\t%a.LogoutLink.span-1.last{:href => login_path, :title => 'Login'} Login\n"

  header.gsub!('<a class="LoginLink span-1 last" id="login" href="/panel/login" title="Anmelden">Anmelden</a>',login_switch)
  
  write_to = File.new(Rails.root + "app/views/layouts/_header.html.haml", "w+")
	write_to.puts(header[0,header.length-16]) #extreme ugly because nokogiri add </body></html> at the end of its document

	write_to = File.new(Rails.root + "app/views/layouts/footer.html", "w+")
	write_to.puts(html[html.index(marker_footer)+marker_footer.length,html.length])
 
rescue Exception => e
	puts "Can't generate static HTML Header and Footer! Do nothing!"
	puts "ERROR: #{e}"
end

