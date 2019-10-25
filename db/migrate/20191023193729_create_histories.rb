class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.string :place_type
      t.string :lat
      t.string :lng
      t.string :google_place_id
      t.jsonb :preferences
      t.timestamps
    end
  end
end
