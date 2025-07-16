class MigrateGoodAnsThemesToGoodAnsGames < ActiveRecord::Migration[8.0]
  def up
    # 既存のgood_ans_themesデータをGoodAnsGameに移行
    Room.where.not(good_ans_themes: nil).find_each do |room|
      next if room.good_ans_themes.blank?

      GoodAnsGame.create!(
        room: room,
        themes: room.good_ans_themes,
        status: 'waiting'
      )
    end
  end

  def down
    # ロールバック時はGoodAnsGameのデータをroomに戻す
    GoodAnsGame.find_each do |game|
      game.room.update_column(:good_ans_themes, game.themes)
    end
  end
end
