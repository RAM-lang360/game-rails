class AddJoinIdToRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :join_id, :integer
    add_foreign_key :rooms, :join_users, column: :join_id
  end
end
