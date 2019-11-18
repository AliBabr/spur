class AddColumnToUserTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :arrival_notification, :boolean, default: false
    rename_column :users, :notification_status, :pickup_notification
  end
end
