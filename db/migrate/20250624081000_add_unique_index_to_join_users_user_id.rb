class AddUniqueIndexToJoinUsersUserId < ActiveRecord::Migration[6.0]
  def change
    add_index :join_users, :user_id, unique: true
  end
end
