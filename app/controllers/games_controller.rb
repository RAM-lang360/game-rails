class GamesController < ApplicationController
  before_action :find_room # drawアクションが実行される前にテーマをロード
  before_action :load_themes, only: [ :draw ]
  def good_ans
    # ホストがゲーム開始パラメータ付きでアクセスした場合のみブロードキャスト
    if params[:start_game] == "true" && current_user.id == @room.host_id
      broadcast_game_start

      # セッションにテーマを初期化
      puts "ゲーム開始のためのテーマを初期化します"
      @themes = AnsTheme.pluck(:text).shuffle
    end
  end

  def load_themes
    # セッションからテーマをロード
    @themes = session["room_#{@room.id}_themes"]
    puts "ロードされたテーマ: #{@themes.inspect}"
  end
  def draw
    # load_themes で @themes は既にロードされている
    # テーマをランダムに選択し、配列から削除
    @drawn_theme = @themes.delete(@themes.sample)

    # セッションのテーマを更新
    session["room_#{@room.id}_themes"] = @themes

    puts "選択されたテーマ: #{@drawn_theme}"
    # broadcast_draw
  end

  private

  def find_room
    @room = Room.find(params[:id])
  end

  # drawアクションの前にテーマをセッションからロードす

  def broadcast_game_start
    puts "ブロードキャストされてるよ"
    ActionCable.server.broadcast(
      "navigation_room_#{@room.id}",
      {
        action: "redirect",
        url: good_ans_game_path(@room),
        message: "ホストが朝までそれ正解を開始しました"
      }
    )
    puts "ルーム#{@room.id}の全ユーザーにgood_ansゲーム開始をブロードキャストしました"
  end

  def broadcast_draw
    ActionCable.server.broadcast(
      "good_ans_channel",
      {
        action: "draw",
        theme: @drawn_theme,
        remaining_themes: @themes
      }
    )
    puts "ルーム#{@room.id}の全ユーザーに抽選結果をブロードキャストしました"
  end
end
