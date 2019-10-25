class AddUserToHistoryAndReferences < ActiveRecord::Migration[5.2]
  def change
    add_column :histories, :user_id, :string, references: :users
    add_column :preferences, :user_id, :string, references: :users
  end
end
