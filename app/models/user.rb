class User < ActiveRecord::Base
  acts_as_authentic
  has_and_belongs_to_many :permissions

  def may_edit_calendar?
    !calendar_permissions.blank?
  end
  
  def calendar_permissions
    permissions.select{|p| p.source == 'calendar' && p.access == 'create'}
  end
end
