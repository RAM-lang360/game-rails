class CreateJoinUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :join_users do |t|
      t.integer :user_id, null: false
      t.timestamps
    end
  end
end
