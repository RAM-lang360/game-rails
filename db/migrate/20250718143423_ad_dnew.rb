class AdDnew < ActiveRecord::Migration[8.0]
  def change
    add_column :good_ans_games, :answers, :jsonb, default: []
  end
end
