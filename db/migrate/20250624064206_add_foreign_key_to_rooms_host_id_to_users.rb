class AddForeignKeyToRoomsHostIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :rooms, :users, column: :host_id
  end
end
