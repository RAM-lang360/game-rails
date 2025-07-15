class BackRoomChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    room_id = params[:room_id]
    stream_from "back_room_#{room_id}"
    puts "ユーザーがルーム#{room_id}のバックルームチャンネルに接続しました"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
