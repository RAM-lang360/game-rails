class DropJoinUsers < ActiveRecord::Migration[6.0]
  def change
    drop_table :join_users do |t|
      t.integer :user_id, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
