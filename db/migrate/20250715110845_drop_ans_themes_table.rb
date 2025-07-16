class DropAnsThemesTable < ActiveRecord::Migration[8.0]
  def up
    drop_table :ans_themes
  end

  def down
    create_table :ans_themes do |t|
      t.timestamps
    end
  end
end
