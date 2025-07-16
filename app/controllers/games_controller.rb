class GamesController < ApplicationController
  before_action :find_room
  before_action :find_or_create_game, only: [ :good_ans, :draw ]

  def good_ans
    if params[:start_game] == "true" && current_user.id == @room.host_id
      broadcast_game_start

      puts "ゲーム開始のためのテーマを初期化します"
      @game.initialize_themes!
      @game.update!(status: "playing")

      puts "ゲームが正常に初期化されました: #{@game.themes.inspect}"
    end

    @user_names = User.where(room_id: @room.id).pluck(:name)
  end

  def draw
    puts "=== DRAW ACTION START ==="

    if @game.themes.empty?
      puts "ERROR: テーマがありません"
      render json: { success: false, error: "テーマが見つかりません" }
      return
    end
      drawn_theme = @game.draw_theme!

      puts "選択されたテーマ: #{drawn_theme}"
      puts "残りのテーマ数: #{@game.remaining_themes_count}"

      # ゲーム終了判定
      if @game.remaining_themes_count == 0
        @game.update!(status: "finished")
      else
        broadcast_draw
      end
  end

  private

  def find_room
    @room = Room.find(params[:id])
  end

  def find_or_create_game
    @game = @room.good_ans_game || @room.create_good_ans_game!
  end

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
  end

  def broadcast_draw
    ActionCable.server.broadcast(
      "good_ans_channel",
      {
        action: "draw",
        theme: @game.current_theme,
        remaining_themes: @game.remaining_themes_count
      }
    )
  end
end
