class Permission < ActiveRecord::Base
  
  has_and_belongs_to_many :users
  
  def access
    name.split('_').second
  end

  def table
    name.split('_').third
  end
  
  def column
    name.split('_').fourth
  end
  
  def self.all_tables
    Permission.all.map{|p| p.table}.uniq
  end
end
