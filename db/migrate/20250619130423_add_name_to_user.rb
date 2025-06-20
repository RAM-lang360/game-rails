class AddNameToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string, null: false
    remove_column :users, :email_address, :string
  end
end
