class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :hosted_rooms, class_name: "Room", foreign_key: "host_id"
  validates :name, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }


  def broadcast_join_user_content
    puts "ブロードキャスト参加者更新"
    join_user = User.where(room_id: self.room_id, user_status: false).pluck(:name)
    puts "参加者: #{join_user.inspect}"
    Turbo::StreamsChannel.broadcast_replace_to(
      "join_user_channel",
      target: "join_user_content", # ターゲットのID
      partial: "lobby/join_user_content",
      locals: { join_user: join_user }
    )
  end
end
