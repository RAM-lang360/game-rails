class RemoveGoodAnsThemesFromRooms < ActiveRecord::Migration[8.0]
  def change
    remove_column :rooms, :good_ans_themes, :jsonb
  end
end
