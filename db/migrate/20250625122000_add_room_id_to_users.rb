class AddRoomIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :room_id, :integer
    add_foreign_key :users, :rooms, column: :room_id
    add_index :users, :room_id
  end
end
