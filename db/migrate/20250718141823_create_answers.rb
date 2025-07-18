class CreateAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :answers do |t|
      t.references :good_ans_game, null: false, foreign_key: true
      t.string :user_name, null: false
      t.text :content, null: false
      t.datetime :submitted_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end

    # インデックスを追加
    add_index :answers, [:good_ans_game_id, :submitted_at]
    add_index :answers, :user_name
  end
end
