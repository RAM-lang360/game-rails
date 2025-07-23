class GamesController < ApplicationController
  before_action :find_room
  before_action :find_or_create_game, only: [ :good_ans, :draw ]
  before_action :find_good_ans_game, only: [ :good_ans, :post ]
  def good_ans
    if params[:start_game] == "true" && current_user.id == @room.host_id
      broadcast_game_start

      puts "ゲーム開始のためのテーマを初期化します"
      @good_ans_game.initialize_themes!
      @good_ans_game.update!(status: "playing", answers: [])
      @good_ans_game.current_theme = GoodAnsGame.draw_theme!(@room.id)
      puts "ゲームが初期化されました: #{@good_ans_game.inspect}"
    end

    # もし間違ってリログした時でもお題とアンサーを表示してくれる
    @current_theme=@good_ans_game.current_theme if @good_ans_game.current_theme.present?
    @answers = @good_ans_game.answers if @good_ans_game.answers.present?

    puts "ゲームの状態: #{@good_ans_game.status}"
    puts "現在のお題: #{@current_theme}"
    puts "回答一覧: #{@answers.inspect}"

    # もしnew_questionのリダイレクトだった時は以下を実行
    if params[:latest_game] == "true" && current_user.id == @room.host_id
      broadcast_game_start_from_answer
      draw
    end
  end

  def answer
    @good_ans_game = GoodAnsGame.find_by(room_id: @room.id)
    # もし間違ってリログした時でもお題とアンサーを表示してくれる
    @current_theme=@good_ans_game.current_theme if @good_ans_game.current_theme.present?
    @answers = @good_ans_game.answers if @good_ans_game.answers.present?

    puts "ゲームの状態: #{@good_ans_game.status}"
    puts "現在のお題: #{@current_theme}"
    puts "回答一覧: #{@answers.inspect}"
  end
  def post
    if params[:content].blank?
      render json: { success: false, error: "メッセージが空です" }, status: :unprocessable_entity
    else
      user_name = current_user.name
      content = params[:content]

      if @good_ans_game.add_user_answer_to_jsonb(user_name, content)
      end
    end
  end

  def show_answer
  @content_id = params[:content_id]
  broadcast_answer_show
  render json: { success: true, content_id: @content_id }
  end

  # def new_question
  #   puts "=== NEW QUESTION ACTION START ==="
  #   broadcast_game_start_from_answer
  #   draw
  # end

  def draw
    puts "=== DRAW ACTION START ==="

    if @game.themes.empty?
      puts "ERROR: テーマがありません"
      render json: { success: false, error: "テーマが見つかりません" }
      return
    end
      drawn_theme = @game.draw_theme!

      # ゲーム終了判定
      if @game.remaining_themes_count == 0
        @game.update!(status: "finished")
      else
        broadcast_draw
      end
  end

  private

  def find_good_ans_game
    @good_ans_game = GoodAnsGame.find_or_create_by(room_id: @room.id)
  end
  def find_room
    @room = Room.find(params[:id])
    # ユーザーが現在のルームに参加しているか確認
    unless current_user.room_id == @room.id
      redirect_to lobby_index_path, alert: "このルームに参加していません"
    end
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
 def broadcast_game_start_from_answer
    ActionCable.server.broadcast(
      "good_ans_channel_#{@room.id}",
      {
        action: "redirect",
        message: "ゲーム画面に移動します",
        url: good_ans_game_path(@room.id)
      }
    )
  end
  def broadcast_draw
    puts "ブロードキャストされてるよ"
    ActionCable.server.broadcast(
      "good_ans_channel_#{@room.id}",
      {
        action: "draw",
        theme: @game.current_theme,
        remaining_themes: @game.remaining_themes_count
      }
    )
  end

  def broadcast_answer_show
    puts "ブロードキャストされてるよddddddddddddddd"
    ActionCable.server.broadcast(
      "good_ans_channel_#{@room.id}",
      {
        action: "show_answer",
        content_id: @content_id
      }
    )
  end
end
