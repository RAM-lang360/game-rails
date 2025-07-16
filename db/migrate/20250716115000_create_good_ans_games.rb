class CreateGoodAnsGames < ActiveRecord::Migration[8.0]
  def change
    create_table :good_ans_games do |t|
      t.references :room, null: false, foreign_key: true, index: { unique: true }
      t.jsonb :themes, default: []
      t.string :status, default: 'waiting' # waiting, playing, finished
      t.string :current_theme

      t.timestamps
    end
  end
end
