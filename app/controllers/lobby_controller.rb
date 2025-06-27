class LobbyController < ApplicationController
  def index
    @rooms = Room.all
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
      redirect_to lobby_index_path, notice: "ルームを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:room_name, :password)
  end
end
