class AddRoomIdToJoinUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :join_users, :room_id, :integer
    add_foreign_key :join_users, :rooms, column: :room_id
    add_index :join_users, :room_id
  end
end
