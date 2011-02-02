namespace :permissions do
  desc "Looks up all columns from tables beginning with data_ and creates read/write Permissions for them"
  task :init => :environment do
    exclude_list = ['id', 'created_at', 'updated_at']
    ActiveRecord::Base.connection.tables.select{|t| t =~ /^data_/}.each do |table|
      table_name = table.split('_').second
      puts "Creating permissions for table #{table_name}"
      ActiveRecord::Base.connection.columns(table).each do |column|
        next if exclude_list.include?(column.name)
        %w[create read update delete].each do |access|
          if Permission.find_by_access_and_table_and_column(access, table_name, column.name).blank?
	        Permission.create(:access => access, :table => table_name, :column => column.name)
	      end    
        end
      end
    end
  end
end
