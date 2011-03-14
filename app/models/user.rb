class User < ActiveRecord::Base
  acts_as_authentic
  has_and_belongs_to_many :permissions

  def may_create_calendar?
    !calendar_create_permissions.blank?
  end

  def may_read_calendar?
    !calendar_read_permissions.blank?
  end
  
  def may_update_calendar?
    !calendar_update_permissions.blank?
  end

  def may_delete_calendar?
    !calendar_delete_permissions.blank?
  end
  
  def calendar_create_permissions
    permissions.select{|p| p.source == 'calendar' && p.access == 'create'}
  end

  def calendar_read_permissions
    permissions.select{|p| p.source == 'calendar' && p.access == 'read'}
  end

  def calendar_update_permissions
    permissions.select{|p| p.source == 'calendar' && p.access == 'update'}
  end

  def calendar_delete_permissions
    permissions.select{|p| p.source == 'calendar' && p.access == 'delete'}
  end
end
