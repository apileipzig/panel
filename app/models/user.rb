# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  acts_as_authentic

  has_and_belongs_to_many :permissions
  def may_create_resource?(source, table)
    !table_permissions(source, table, 'create').blank?
  end

  def may_read_resource?(source, table)
    !table_permissions(source, table, 'read').blank?
  end

  def may_update_resource?(source, table)
    !table_permissions(source, table, 'update').blank?
  end

  def may_delete_resource?(source, table)
    !table_permissions(source, table, 'delete').blank?
  end

  def table_permissions(source, table, access)
    permissions.select{|p| p.source == source && p.table == table && p.access == access}
  end

  def source_permissions(source, access)
    permissions.select{|p| p.source == source && p.access == access}
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    EmailNotifier.deliver_password_reset_instructions(self)
  end
  
  def initialize_permissions
    self.permissions = Permission.all_read + Permission.all_count
    self.save
  end
end
