class GoodAnsGame < ApplicationRecord
  belongs_to :room

  validates :status, inclusion: { in: %w[waiting playing finished] }
  

def add_user_answer_to_jsonb(user_name, content)
    # 回答内容が空かどうかをチェック
    if content.blank?
      errors.add(:answers, "メッセージが空です")
      return false
    end

    # 新しい回答データをハッシュとして作成
    # JSONB の制約に合わせて {"ユーザー名": "回答内容"} の形式にする
    new_answer_entry = { user_name => content }

    # 既存の配列に新しいハッシュを追加
    self.answers << new_answer_entry

    # モデルインスタンスを保存し、データベースに永続化
    if save
      broadcast_answer
      true # 保存成功
    else
      false # 保存失敗 (バリデーションエラーなど)
    end
  end


  def draw_theme!
    return nil if themes.empty?

    #answersのリセット
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
    Turbo::StreamsChannel.broadcast_replace_to(
      "answers", 
      target: "answers", # ターゲットのID
      partial: "games/answers",
      locals: { room_id: self.room_id, answers: self.answers}  # パーシャルに渡す変数
    )
  end
end
