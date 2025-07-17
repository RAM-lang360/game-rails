class MessagesChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room_id]
    stream_from "message_channel_#{room_id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def receive(data)
    #受け取ったメッセージを処理して他のコンシューマーにブロードキャストする
    ActionCable.server.broadcast("message_chennel",data)
  end
end
