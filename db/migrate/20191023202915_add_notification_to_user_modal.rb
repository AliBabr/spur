class AddNotificationToUserModal < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notification_status, :boolean, default: false
  end
end
