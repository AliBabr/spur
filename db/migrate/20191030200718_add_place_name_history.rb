class AddPlaceNameHistory < ActiveRecord::Migration[5.2]
  def change
    add_column :histories, :name, :string
  end
end
