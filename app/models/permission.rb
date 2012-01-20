# -*- encoding : utf-8 -*-
class Permission < ActiveRecord::Base
  
  has_and_belongs_to_many :users
  
  def self.all_tables
    Permission.all.map{|p| p.table}.uniq
  end

  def self.all_sources
    Permission.all.map{|p| p.source}.uniq
  end
  
  def self.all_read
    Permission.all.select{|p| p.access == 'read'}
  end
  
  def self.all_count
    Permission.all.select{|p| p.access == 'count'}
  end
end
