class ChangeTypeUsersId < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :id, :string
  end
end
