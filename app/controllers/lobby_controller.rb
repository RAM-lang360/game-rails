class LobbyController < ApplicationController
  before_action :find_room, only: [ :show, :destroy ]
  before_action :find_join_user, only: [ :show ]

  def index
    @rooms = Room.all
    @room = Room.new
    @join_room = Room.new
  end

  def new
    @room = Room.new
  end

  def create_room
    return render_room_error("あなたはすでに他のルームのホストです") if Room.exists?(host_id: current_user.id)
    return render_room_error("あなたはすでに他のルームに参加しています") if current_user.room_id.present?
    return render_room_error("そのルームはすでに使用されています") if Room.exists?(room_name: room_params[:room_name])

    @room = build_room_with_host
    if @room.save
      update_user_room_status(@room.id, true)
      redirect_to lobby_path(@room), notice: "ルームを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join_room
    @join_room = Room.new
    @join_room.room_name = params[:room_name] if params[:room_name].present?
    @rooms = Room.all
    @room = Room.new
  end

  def join
    @join_room = Room.find_by(room_name: params[:room][:room_name])
    return render_join_error("指定されたルームが見つかりません") unless @join_room
    return render_join_error("あなたは既に他のルームに参加しています") if other_room_joined?
    return render_join_error("既にこのルームに参加済みです") if same_room_joined?

    if @join_room.authenticate(params[:room][:room_password])
      if update_user_room_status(@join_room.id, false)
        current_user.broadcast_join_user_content(@join_room.id)
        redirect_to lobby_path(@join_room), notice: "ルームに参加しました"
      else
        render_join_error("参加に失敗しました。管理者に連絡してください")
      end
    else
      render_join_error("ルーム名またはパスワードが間違っています")
    end
  end

  def show
    @join_user = User.where(room_id: @room.id, user_status: false).pluck(:name)
    broadcast_back_room_from_game if params[:back_room] == "true" && current_user.room_id == @room.id
  end

  def destroy
    if @room.host_id == current_user.id
      @room.destroy
      broadcast_back_room_to_lobby
      redirect_to lobby_index_path, notice: "ルームを削除しました"
    else
      redirect_to lobby_index_path, alert: "ルームの削除に失敗しました"
    end
  end

  def logout
    Current.session&.destroy
    logout_room if current_user.room_id.present?
    redirect_to sessions_path, notice: "ログアウトしました"
  end

  def logout_room
    @room = Room.find(params[:id])

    if can_logout_from_room?
      if update_user_room_status(nil, nil)
        current_user.broadcast_join_user_content(@room.id)
        redirect_to lobby_index_path, notice: "ルームから退出しました"
      else
        redirect_to lobby_path(@room), alert: "ルームからの退出に失敗しました"
      end
    else
      redirect_to lobby_index_path, alert: "このルームに参加していません"
    end
  end

  private

  def find_room
    @room = Room.find(params[:id])
    unless current_user.room_id == @room.id
      redirect_to lobby_index_path, alert: "このルームに参加していません"
    end
  end

  def find_join_user
    @join_user = User.where(room_id: @room.id, user_status: false).pluck(:name)
  end

  def room_params
    params.require(:room).permit(:room_name, :password)
  end

  # エラーハンドリング
  def render_room_error(message)
    @room = Room.new(room_params)
    @room.errors.add(:base, message)
    render :new, status: :unprocessable_entity
  end

  def render_join_error(message)
    setup_join_room_variables
    @join_room.errors.add(:base, message)
    render :join_room, status: :unprocessable_entity
  end

  def setup_join_room_variables
    @rooms = Room.all
    @room = Room.new
    @join_room = Room.new
  end

  # ルーム関連のヘルパー
  def build_room_with_host
    room = Room.new(room_params)
    room.host_id = current_user.id
    room
  end

  def update_user_room_status(room_id, user_status)
    user = User.find(current_user.id)
    user.room_id = room_id
    user.user_status = user_status unless user_status.nil?
    user.save
  end

  # 条件チェック
  def other_room_joined?
    current_user.room_id.present? && current_user.room_id != @join_room.id
  end

  def same_room_joined?
    current_user.room_id == @join_room.id
  end

  def can_logout_from_room?
    current_user.room_id == @room.id && current_user.user_status == false
  end

  # ブロードキャスト
  def broadcast_back_room_from_game
    ActionCable.server.broadcast(
      "back_room_#{@room.id}",
      {
        action: "redirect",
        url: lobby_path(@room),
        message: "ルーム部屋に移動します。"
      }
    )
  end

  def broadcast_back_room_to_lobby
    ActionCable.server.broadcast(
      "navigation_room_#{@room.id}",
      {
        action: "redirect",
        url: lobby_index_path,
        message: "ロビーに移動します。"
      }
    )
  end
end
