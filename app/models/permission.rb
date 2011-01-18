class Permission < ActiveRecord::Base
  
  has_and_belongs_to_many :users
  
  def self.all_tables
    Permission.all.map{|p| p.tabelle}.uniq
  end
end
