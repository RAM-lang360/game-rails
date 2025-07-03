module ApplicationHelper
  def user_status
    if current_user
      name = current_user.name
      room_id = current_user.room_id
      "ユーザー名: #{name}<br>ルームID: #{room_id}".html_safe
    else
      "ログインしていません"
    end
  end

  def back_room
    return "#" unless current_user&.room_id.present?

    lobby_path(current_user.room_id)
  end
end
