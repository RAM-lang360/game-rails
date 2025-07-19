class Room < ApplicationRecord
  # host_idカラムがUserモデルを参照することを明示
  has_secure_password
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  # join_idカラムがJoinUserモデルを参照することを明示
  belongs_to :join_user, foreign_key: :join_id, optional: true
  has_one :good_ans_game, dependent: :destroy

  validates :room_name, presence: true
  validates :password, presence: true

  after_create_commit :broadcast_room_creation
  after_destroy_commit :broadcast_room_deletion



  private

  def broadcast_room_creation
    rooms= Room.all
    Turbo::StreamsChannel.broadcast_replace_to(
      "display_rooms",
      target: "lobby-rooms",
      partial: "lobby/rooms_content",
      locals: { rooms: rooms }
    )
    puts "ルーム作成をブロードキャスト #{self.room_name}"
  end

  def broadcast_room_deletion
    rooms= Room.all
    Turbo::StreamsChannel.broadcast_replace_to(
      "display_rooms",
      target: "lobby-rooms",
      partial: "lobby/rooms_content",
      locals: { rooms: rooms }
    )
    puts "ルーム作成をブロードキャスト #{self.room_name}"
  end
end
