class RemoveEmailAddressFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :email_address, :string
  end
end
