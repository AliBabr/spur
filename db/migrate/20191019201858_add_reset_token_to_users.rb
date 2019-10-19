class AddResetTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :reset_token, :string
  end
end
