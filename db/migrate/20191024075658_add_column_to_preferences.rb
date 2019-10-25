class AddColumnToPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :price_level, :integer
  end
end
