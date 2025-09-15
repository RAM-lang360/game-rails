class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :room_name
      t.string :password
      t.references :host, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :rooms, :room_name, unique: true
  end
end
