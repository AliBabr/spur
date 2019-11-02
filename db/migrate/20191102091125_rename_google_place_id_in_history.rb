class RenameGooglePlaceIdInHistory < ActiveRecord::Migration[5.2]
  def change
    rename_column :histories, :google_place_id, :place_id
  end
end
