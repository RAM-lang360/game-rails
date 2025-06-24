class DropRoomUsers < ActiveRecord::Migration[8.0]
  def up
    # `rails db:migrate` を実行した時の処理
    drop_table :room_users
  end

  def down
    # `rails db:rollback` を実行した時の処理
    # ここに、`room_users`テーブルを再作成する処理を正確に書く
    create_table :room_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
    add_index :room_users, [ :user_id, :room_id ], unique: true
  end
end
