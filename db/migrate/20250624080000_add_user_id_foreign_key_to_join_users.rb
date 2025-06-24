class AddUserIdForeignKeyToJoinUsers < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :join_users, :users, column: :user_id
  end
end
