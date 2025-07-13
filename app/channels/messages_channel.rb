class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "message_chennel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
  
  def receive(data)
    #受け取ったメッセージを処理して他のコンシューマーにブロードキャストする
    ActionCable.server.broadcast("message_chennel",data)
  end
end
