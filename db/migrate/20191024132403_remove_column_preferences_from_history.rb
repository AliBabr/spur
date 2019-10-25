class RemoveColumnPreferencesFromHistory < ActiveRecord::Migration[5.2]
  def change
    remove_column :histories, :preferences
  end
end
