class NavigationChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:room_id]
    stream_from "navigation_room_#{room_id}"
    puts "ユーザーがルーム#{room_id}のナビゲーションチャンネルに接続しました"
  end

  def unsubscribed
    puts "ナビゲーションチャンネルから切断されました"
  end
end
