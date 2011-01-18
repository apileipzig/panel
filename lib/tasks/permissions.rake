namespace :permissions do
  desc "Looks up all columns from tables beginning with data_ and creates read/write Permissions for them"
  task :init => :environment do
    ActiveRecord::Base.connection.tables.select{|t| t =~ /^data_/}.each do |table|
      table_name = table.split('_').second
      puts "Creating permissions for table #{table_name}"
      ActiveRecord::Base.connection.columns(table).each do |column|
        %w[read write].each do |access|
          if Permission.find_by_access_and_tabelle_and_spalte(access, table_name, column.name).blank?
	        Permission.create(:access => access, :tabelle => table_name, :spalte => column.name)
	      end    
        end
      end
    end
  end
end
