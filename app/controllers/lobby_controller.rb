class LobbyController < ApplicationController
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
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:room_name, :password)
  end
end
