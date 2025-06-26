class AddUniqueIndexToRoomsHostId < ActiveRecord::Migration[6.0]
  def change
    add_index :rooms, :host_id, unique: true
  end
end
