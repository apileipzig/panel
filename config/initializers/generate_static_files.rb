require 'nokogiri'

marker_header = '<!-- /#Start_Content_Marker - DO NOT (RE)MOVE! -->'
marker_footer = '<!-- /#End_Content_Marker - DO NOT (RE)MOVE! -->'

begin
	html = File.open(Rails.root + '../index.html', 'r') { |f| f.read }

  doc = Nokogiri::HTML(html[0,html.index(marker_header)])

  doc.search('body').each do |e|
    e['class'] = "panel"
  end

  doc.search('a[@id="login"]').each do |e|
    e.remove
  end

  doc.search('section[@id="SignUp"]/a').each do |e|
    e['href'] = "/panel/"
    e.content = "Mitgliederbereich"
  end
  header = doc.to_s

  write_to = File.new(Rails.root + "app/views/layouts/header.html", "w+")
	write_to.puts(header[0,header.length-16]) #extreme ugly because nokogiri add </body></html> at the end of its document

	write_to = File.new(Rails.root + "app/views/layouts/footer.html", "w+")
	write_to.puts(html[html.index(marker_footer)+marker_footer.length,html.length])
 
rescue Exception => e
	puts "Can't generate static HTML Header and Footer! Do nothing!"
	puts "ERROR: #{e}"
end

