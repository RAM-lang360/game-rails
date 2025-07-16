class CreateAnsThemes < ActiveRecord::Migration[8.0]
  def change
    create_table :ans_themes do |t|
      t.timestamps
    end
  end
end
