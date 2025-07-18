class RemoveAnswersFromGoodAnsGames < ActiveRecord::Migration[8.0]
  def up
    # 既存のJSONBデータを新しいAnswersテーブルに移行
    GoodAnsGame.find_each do |game|
      next if game.answers.blank?
      
      game.answers.each do |answer_hash|
        user_name = answer_hash.keys.first
        content = answer_hash.values.first
        
        Answer.create!(
          good_ans_game: game,
          user_name: user_name,
          content: content,
          submitted_at: Time.current
        )
      end
    end
    
    # JSONBカラムを削除
    remove_column :good_ans_games, :answers
  end

  def down
    # ロールバック用
    add_column :good_ans_games, :answers, :jsonb, default: []
    
    # Answersテーブルのデータを戻す
    Answer.includes(:good_ans_game).find_each do |answer|
      game = answer.good_ans_game
      game.answers ||= []
      game.answers << { answer.user_name => answer.content }
      game.save!
    end
  end
end
