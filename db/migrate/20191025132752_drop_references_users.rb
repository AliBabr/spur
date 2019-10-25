class DropReferencesUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :preferences, :user_id
    remove_column :histories, :user_id
  end
end
