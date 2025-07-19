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

  def create
    if Room.exists?(host_id: current_user.id)
      @room = Room.new(room_params)
      @room.errors.add(:host_id, "はすでに他のルームのホストです")
      render :new, status: :unprocessable_entity
      return
    end

    @room = Room.new(room_params)
    @room.host_id = current_user.id if current_user
    if @room.save
      # ルーム保存後にユーザーのroom_idを更新
      @user = User.find_by(id: current_user.id)
      @user.room_id = @room.id
      @user.user_status = true # ホストとして設定
      @user.save
      redirect_to lobby_path(@room), notice: "ルームを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def join_room
    @join_room = Room.new
    @rooms = Room.all
    @room = Room.new
    # ルーム参加のためのフォームを表示
  end

  def join
    @join_room = Room.find_by(room_name: params[:room][:room_name])
    unless @join_room
      @rooms = Room.all
      @room = Room.new
      @join_room = Room.new
      @join_room.errors.add(:base, "指定されたルームが見つかりません")
      render :index, status: :unprocessable_entity
      return
    end

    # ユーザーが既に他のルームに参加している場合のチェック
    if current_user.room_id.present? && current_user.room_id != @join_room.id
      @rooms = Room.all
      @room = Room.new
      @temp_room = Room.new
      @temp_room.errors.add(:base, "あなたは既に他のルームに参加しています")
      @join_room = @temp_room
      render :index, status: :unprocessable_entity
      return
    end

    # 既に同じルームに参加している場合のチェック
    if current_user.room_id == @join_room.id || current_user.room_id == @join_room.host_id
      redirect_to lobby_index_path, notice: "既にこのルームに参加済みです"
      return
    end

    if @join_room.authenticate(params[:room][:room_password])
      @user = User.find_by(id: current_user.id)
      @user.room_id = @join_room.id

      if @user.save
        puts "------------------------------------erjpi参加者を更新します"
        @user.broadcast_join_user_content
        redirect_to lobby_path(@join_room), notice: "ルームを作成しました"
      else
        redirect_to lobby_index_path, alert: "参加に失敗しました"
      end
    else
      @rooms = Room.all
      @room = Room.new
      @join_room.errors.add(:base, "ルーム名またはパスワードが間違っています")
      render :index, status: :unprocessable_entity
    end
  end

  def show
    if params[:back_room] == "true" && current_user.room_id == @room.id
      broadcast_back_room_from_game
    end
  end

  def destroy
    @room = Room.find(params[:id])
    if @room.host_id == current_user.id
      @room.destroy
      redirect_to lobby_index_path, notice: "ルームを削除しました"
      # ページ遷移
      puts "---------------ルーム削除後のブロードキャストを実行します----------------"
      broadcast_back_room_to_lobby
    else
      redirect_to lobby_index_path, alert: "ルームの削除に失敗しました"
    end
  end

  def logout
    Current.session&.destroy
    redirect_to sessions_path, notice: "ログアウトしました"
  end


  private

  def find_room
    @room = Room.find(params[:id])
    # ユーザーが現在のルームに参加しているか確認
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

  def broadcast_back_room_from_game
    ActionCable.server.broadcast(
      "back_room_#{@room.id}",
      {
        action: "redirect",
        url: lobby_path(@room),
        message: "ルーム部屋に移動します。"
      }
    )
    puts "ルーム#{@room.id}の全ユーザーにgood_ansゲーム開始をブロードキャストしました"
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
