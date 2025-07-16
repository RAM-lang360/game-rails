module GamesHelper
  def display_users(user_names)
    if user_names.present?
      # h2とulを配列に入れてsafe_joinで結合
      safe_join([
        content_tag(:h2, "参加者一覧"),
        content_tag(:ul) do
          user_names.map { |name| content_tag(:li, name) }.join.html_safe
        end
      ])
    else
      "ユーザー情報なし"
    end
  end
end
