class GamesController < ApplicationController
  before_action :find_room
  before_action :find_good_ans_game, only: [ :good_ans, :answer, :post, :draw, :show_answer ]
  before_action :ensure_host, only: [ :good_ans, :draw ], if: -> { start_game_requested? || latest_game_requested? || action_name == "draw" }
  before_action :load_game_state, only: [ :good_ans, :answer ]

  def good_ans
    handle_game_start if start_game_requested?
    handle_latest_game if latest_game_requested?
  end

  def answer
    # ゲーム状態は before_action で読み込み済み
    # redirect_to answer_path を削除（無限ループの原因）
  end

  def post
    return render_error("メッセージが空です") if params[:content].blank?

    if @good_ans_game.add_user_answer_to_jsonb(current_user.id, params[:content])
      redirect_to answer_path
    else
      redirect_to good_ans_game_path(@room), alert: "回答の保存に失敗しました"
    end
  end

  def show_answer
    @content_id = params[:content_id]
    broadcast_to_room("show_answer", content_id: @content_id)
    render json: { success: true, content_id: @content_id }
  end

  def draw
    return render_error("テーマが見つかりません") if @good_ans_game.themes.empty?

    @good_ans_game.draw_theme!

    if @good_ans_game.remaining_themes_count == 0
      @good_ans_game.update!(status: "finished")
      render json: { success: true, message: "全てのテーマが終了しました" }
    else
      broadcast_to_room("draw",
        theme: @good_ans_game.current_theme,
        remaining_themes: @good_ans_game.remaining_themes_count
      )
      # render json: { success: true, theme: @good_ans_game.current_theme }
    end
  rescue => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end

  private

  def find_room
    @room = Room.find(params[:id])
    redirect_to_lobby("このルームに参加していません") unless user_in_room?
  end

  def find_good_ans_game
    @good_ans_game = GoodAnsGame.find_or_create_by(room_id: @room.id)
  end

  def ensure_host
    redirect_to_lobby("ホストのみ実行可能です") unless current_user.id == @room.host_id
  end

  def load_game_state
    @current_theme = @good_ans_game.current_theme
    @answers = @good_ans_game.answers || []
    log_game_state
  end

  def handle_game_start
    log_info("ゲーム開始のためのテーマを初期化します")
    @good_ans_game.initialize_themes!
    @good_ans_game.update!(status: "playing", answers: [])
    @good_ans_game.draw_theme!

    broadcast_to_navigation("redirect",
      url: good_ans_game_path(@room),
      message: "ホストが朝までそれ正解を開始しました"
    )
    log_info("ゲームが初期化されました")
  end

  def handle_latest_game
    broadcast_to_room("redirect",
      message: "ゲーム画面に移動します",
      url: good_ans_game_path(@room.id)
    )
    draw
  end

  # ヘルパーメソッド
  def start_game_requested?
    params[:start_game] == "true"
  end

  def latest_game_requested?
    params[:latest_game] == "true"
  end

  def user_in_room?
    current_user.room_id == @room.id
  end

  def redirect_to_lobby(message)
    redirect_to lobby_index_path, alert: message
  end

  def render_error(message)
    render json: { success: false, error: message }, status: :unprocessable_entity
  end

  def log_game_state
    log_info("ゲームの状態: #{@good_ans_game.status}")
    log_info("現在のお題: #{@current_theme}")
    log_info("回答一覧: #{@answers.inspect}")
  end

  def log_info(message)
    puts message
  end

  # ブロードキャスト関連
  def broadcast_to_room(action, data = {})
    log_info("ブロードキャストされてるよ")
    ActionCable.server.broadcast(
      "good_ans_channel_#{@room.id}",
      { action: action }.merge(data)
    )
  end

  def broadcast_to_navigation(action, data = {})
    log_info("ブロードキャストされてるよ")
    ActionCable.server.broadcast(
      "navigation_room_#{@room.id}",
      { action: action }.merge(data)
    )
  end
end
