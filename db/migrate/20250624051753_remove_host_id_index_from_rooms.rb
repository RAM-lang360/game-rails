# db/migrate/YYYYMMDDHHMMSS_remove_host_id_index_from_rooms.rb

class RemoveHostIdIndexFromRooms < ActiveRecord::Migration[8.0]
  def change
    remove_index :rooms, :host_id
  end
end
