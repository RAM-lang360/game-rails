class AddYourJsonbColumnToRooms < ActiveRecord::Migration[8.0]
  def change
    add_column :rooms, :good_ans_themes, :jsonb
  end
end
