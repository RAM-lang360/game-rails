class GamesController < ApplicationController
  before_action :find_room, only: [ :good_ans, :draw ]

  def good_ans
    # ホストがゲーム開始パラメータ付きでアクセスした場合のみブロードキャスト
    if params[:start_game] == "true" && current_user.id == @room.host_id
      broadcast_game_start
      # テーマをルームにjson形式で保存
      puts "ゲーム開始のためのテーマを初期化します"
      @themes = AnsTheme.pluck(:text).shuffle
      @room.update_columns(good_ans_themes: @themes)
      puts "ルーム情報: #{@room.inspect}"
    end
  end
  def draw
    # load_themes で @themes は既にロードされている
    # テーマをランダムに選択し、配列から削除

    @drawn_theme = @room.good_ans_themes.first
    if @drawn_theme.nil?
      puts "利用可能なテーマがありません"
      redirect_to lobby_path(@room, back_room: "true")
    else
    @remaining_themes = @room.good_ans_themes - [ @drawn_theme ]
    @room.update_columns(good_ans_themes: @remaining_themes) # 更新されたテーマを保存
    puts "選択されたテーマ: #{@drawn_theme}"
    broadcast_draw
    end
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
        theme: @drawn_theme
      }
    )
    puts "ルーム#{@room.id}の全ユーザーに抽選結果をブロードキャストしました"
  end
end
