class Changethemes < ActiveRecord::Migration[8.0]
    def change
    rename_column :rooms, :your_jsonb_column_name, :good_ans_themes
  end
end
