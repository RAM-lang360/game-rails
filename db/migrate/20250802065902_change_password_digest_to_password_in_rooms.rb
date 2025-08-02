class ChangePasswordDigestToPasswordInRooms < ActiveRecord::Migration[7.0]
  def change
    rename_column :rooms, :password_digest, :password
  end
end
