class AddUserToHistories < ActiveRecord::Migration[5.2]
  def change
    add_reference :histories, :user, foreign_key: true
  end
end
