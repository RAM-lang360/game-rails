class ChangeAnswersDefaultInGoodAnsGames < ActiveRecord::Migration[8.0]
  def up
    # デフォルト値を[]に変更
    change_column_default :good_ans_games, :answers, from: {}, to: []
    
    # 既存のレコードで{}になっているものを[]に更新
    execute "UPDATE good_ans_games SET answers = '[]'::jsonb WHERE answers = '{}'::jsonb"
  end

  def down
    # ロールバック時は元の{}に戻す
    change_column_default :good_ans_games, :answers, from: [], to: {}
    
    # 既存のレコードで[]になっているものを{}に更新
    execute "UPDATE good_ans_games SET answers = '{}'::jsonb WHERE answers = '[]'::jsonb"
  end
end
