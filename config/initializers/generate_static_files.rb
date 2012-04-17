# -*- encoding : utf-8 -*-
require 'nokogiri'

marker_header = '<!-- /#Start_Content_Marker - DO NOT (RE)MOVE! -->'
marker_footer = '<!-- /#End_Content_Marker - DO NOT (RE)MOVE! -->'

begin
  puts "Generating static files..."

	html = File.open(Rails.root + '../../index.html', 'r') { |f| f.read }

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

  doc.search('section[@id="user"]').each do |e|
    e.inner_html = "\n- if @current_user\n\tHallo,\n\t= link_to @current_user.name, '/panel/account/edit'\n"
  end

  header = doc.to_html
  
  #add login/logout switch to the template string
  login_switch = "\n- if @current_user\n\t%a.LogoutLink.span-1.last{:href => logout_path, :title => 'Abmelden'} Abmelden \n- else\n\t%a.LogoutLink.span-1.last{:href => login_path, :title => 'Anmelden'} Anmelden\n"

  header.gsub!('<a class="LoginLink span-1 last" id="login" href="/panel/login" title="Anmelden">Anmelden</a>',login_switch)
  
  File.open(Rails.root + "app/views/layouts/header.html.haml", "w+") do |f|
    f.write(header[0,header.length-16]) #extreme ugly because nokogiri add </body></html> at the end of its document
  end

  File.open(Rails.root + "app/views/layouts/footer.html", "w+") do |f|
    f.write(html[html.index(marker_footer)+marker_footer.length,html.length])
  end

  #copy fresh static files from the frontend on every startup only on dev mode
  if Rails.env == 'development'
    %x[rm -r public/css]
    %x[rm -r public/js]
    %x[rm -r public/images]
    %x[cp -R ../css public/]
    %x[cp -R ../js public/]
    %x[cp -R ../images public/]
  end
 
rescue Exception => e
	puts "Can't generate static HTML Header and Footer! Do nothing!"
	puts "ERROR: #{e}"
end

