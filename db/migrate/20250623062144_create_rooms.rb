class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :room_name
      t.string :password_digest
      t.references :host, null: false, foreign_key: true

      t.timestamps
    end
    add_index :rooms, :room_name, unique: true
  end
end
