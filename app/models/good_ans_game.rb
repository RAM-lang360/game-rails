class GoodAnsGame < ApplicationRecord
  belongs_to :room

  validates :status, inclusion: { in: %w[waiting playing finished] }


def add_user_answer_to_jsonb(user_name, content)
  if content.blank?
    errors.add(:answers, "メッセージが空です")
    return false
  end

  # user_nameに紐づく既存の回答を探す
  existing_answer_index = self.answers.find_index { |answer_entry| answer_entry.key?(user_name) }

  new_answer_entry = { user_name => content }

  if existing_answer_index # 既存の回答が見つかった場合
    self.answers[existing_answer_index] = new_answer_entry # 上書き
  else # 新しい回答の場合
    self.answers << new_answer_entry # 追加
  end

  # puts "既存の回答者 (更新後): #{self.answers.map { |ans| ans.keys.first }.inspect}" # デバッグ用

  if save
    broadcast_answer
    true
  else
    false
  end
end


  def draw_theme!
    return nil if themes.empty?

    # answersのリセット
    self.answers = []
    # themesからランダムに1つ選び、current_themeに設定
    drawn = themes.shift
    self.current_theme = drawn
    save!
    drawn
  end

  def remaining_themes_count
    themes.size
  end

  def initialize_themes!
    self.themes = AnsTheme.pluck(:text).shuffle
    self.status = "waiting"
    save!
  end


  def broadcast_answer
    puts "モデルテスト #{self.answers}"
    Turbo::StreamsChannel.broadcast_replace_to(
      "answers",
      target: "answers", # ターゲットのID
      partial: "games/answers",
      locals: { room_id: self.room_id, answers: self.answers }  # パーシャルに渡す変数
    )
  end
end
