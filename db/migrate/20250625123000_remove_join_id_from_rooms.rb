class RemoveJoinIdFromRooms < ActiveRecord::Migration[6.0]
  def change
    remove_column :rooms, :join_id
  end
end
