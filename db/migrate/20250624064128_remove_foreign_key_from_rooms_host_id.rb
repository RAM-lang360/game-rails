# db/migrate/YYYYMMDDHHMMSS_add_foreign_key_to_rooms_host_id_to_users.rb

class AddForeignKeyToRoomsHostIdToUsers < ActiveRecord::Migration[8.0]
  def change
    # roomsテーブルのhost_idカラムが、usersテーブルのidカラムを参照するように外部キーを追加
    add_foreign_key :rooms, :users, column: :host_id, primary_key: :id
  end
end
