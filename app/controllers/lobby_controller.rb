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
    if Room.exists?(host_id: current_user.id)
      @room = Room.new(room_params)
      @room.errors.add(:base, "あなたはすでに他のルームのホストです")
      render :new, status: :unprocessable_entity
      return
    end
    if current_user.room_id.present?
      @room = Room.new(room_params)
      @room.errors.add(:base, "あなたはすでに他のルームに参加しています")
      render :new, status: :unprocessable_entity
      return
    end
    # ルーム名が既に存在した時の処理
    if Room.exists?(room_name: params[:room][:room_name])
      @room = Room.new(room_params)
      @room.errors.add(:base, "そのルームはすでに使用されています")
      render :new, status: :unprocessable_entity
      return
    end
    # ルームの作成
    puts "ルームを作成します: #{params[:room][:room_name]}"
    puts "ルームのパスワード: #{params[:room][:password]}"
    @room = Room.new(room_name: params[:room][:room_name], password: params[:room][:password])
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
    # URLパラメータからルーム名を取得して初期値として設定
    @join_room.room_name = params[:room_name] if params[:room_name].present?
    @rooms = Room.all
    @room = Room.new
    # ルーム参加のためのフォームを表示
  end

  def join
    @join_room = Room.find_by(room_name: params[:room][:room_name])
    unless @join_room
      puts "ルームが見つかりませんでした"
      @rooms = Room.all
      @room = Room.new
      @join_room = Room.new
      @join_room.errors.add(:base, "指定されたルームが見つかりません")
      render :join_room, status: :unprocessable_entity
      return
    end

    # ユーザーが既に他のルームに参加している場合のチェック
    if current_user.room_id.present? && current_user.room_id != @join_room.id
      puts "ユーザーは既に他のルームに参加しています"
      @rooms = Room.all
      @room = Room.new
      @temp_room = Room.new
      @temp_room.errors.add(:base, "あなたは既に他のルームに参加しています")
      @join_room = @temp_room
      render :join_room, status: :unprocessable_entity
      return
    end

    # 既に同じルームに参加している場合のチェック
    if current_user.room_id == @join_room.id
      puts "ユーザーは既にこのルームに参加しています"
      @rooms = Room.all
      @room = Room.new
      @join_room.errors.add(:base, "既にこのルームに参加済みです")
      render :join_room, status: :unprocessable_entity
      return
    end

    if @join_room.authenticate(params[:room][:room_password])
      puts "ルーム参加認証成功"
      @user = User.find_by(id: current_user.id)
      @user.room_id = @join_room.id
       @user.user_status = false # 参加者として設定
      if @user.save
        puts "------------------------------------erjpi参加者を更新します"

        @user.broadcast_join_user_content(@join_room.id)
        redirect_to lobby_path(@join_room), notice: "ルームに参加しました"
      else
        @rooms = Room.all
        @room = Room.new
        @join_room.errors.add(:base, "参加に失敗しました。管理者に連絡してください")
        render :join_room, status: :unprocessable_entity
      end
    else
      @rooms = Room.all
      @room = Room.new
      @join_room.errors.add(:base, "ルーム名またはパスワードが間違っています")
      puts "エラーーーーーーーーーーーー#{@join_room.errors.full_messages.join(", ")}"
      render :join_room, status: :unprocessable_entity
    end
  end

  def show
    @join_user = User.where(room_id: @room.id, user_status: false).pluck(:name)
    puts "ルームID: #{@room.id}, 参加者: #{@join_user.inspect}"
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
    logout_room if current_user.room_id.present?
    redirect_to sessions_path, notice: "ログアウトしました"
  end

  def logout_room
    puts "ルームからのログアウト処理を開始します"
    @room = Room.find(params[:id])
    puts "現在のユーザーのルームID: #{current_user.room_id}, ルームID: #{@room.id}, ユーザーステータス: #{current_user.user_status}"
    if current_user.room_id == @room.id && current_user.user_status == false
      @user = User.find_by(id: current_user.id)
      @user.room_id = nil
      if @user.save
        puts "ルームからのログアウト成功"
        @user.broadcast_join_user_content(@room.id)
        # ルームから退出した後、ロビーにリダイレクト
        puts "ルームから退出しました"
        redirect_to lobby_index_path, notice: "ルームから退出しました"
      else
        puts "ルームからのログアウト失敗"
        redirect_to lobby_path(@room), alert: "ルームからの退出に失敗しました"
      end
    else
      puts "ユーザーはこのルームに参加していません"
      redirect_to lobby_index_path, alert: "このルームに参加していません"
    end
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
