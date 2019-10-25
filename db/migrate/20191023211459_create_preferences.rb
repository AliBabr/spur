class CreatePreferences < ActiveRecord::Migration[5.2]
  def change
    create_table :preferences do |t|
      t.jsonb :filters
      t.timestamps
      t.references :user, index: true, foreign_key: true
    end
  end
end
