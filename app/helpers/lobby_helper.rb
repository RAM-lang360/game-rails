module LobbyHelper
  # ルームカードを表示するヘルパー
  def room_card(room)
    content_tag :div, class: "room-card" do
      concat content_tag(:h3, room.room_name, class: "room-name")
      concat content_tag(:p, "ホスト: #{room_host_name(room)}", class: "room-host")
      concat content_tag(:p, "作成日時: #{format_datetime(room.created_at)}", class: "room-created-at")
    end
  end

  # ルームのホスト名を取得
  def room_host_name(room)
    room.host&.name || "不明"
  end

  # ルームの参加者数を取得
  def room_participants(room)
    @users=User.where(room_id: room.id, user_status: false)
  end

  # 日時のフォーマット
  def format_datetime(datetime)
    datetime&.strftime("%Y-%m-%d %H:%M:%S")|| "不明"
  end

  def back_room
    return "#" unless current_user&.room_id.present?

    lobby_path(current_user.room_id)
  end
end
