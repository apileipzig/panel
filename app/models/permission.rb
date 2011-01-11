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
end
