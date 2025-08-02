class Room < ApplicationRecord
  # host_idカラムがUserモデルを参照することを明示
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  # join_idカラムがJoinUserモデルを参照することを明示
  belongs_to :join_user, foreign_key: :join_id, optional: true
  has_one :good_ans_game, dependent: :destroy

  validates :room_name, presence: true, uniqueness: true
  validates :password, presence: true

  after_create_commit :broadcast_room_creation
  after_destroy_commit :broadcast_room_deletion

  # 平文パスワードでの認証メソッド
  def authenticate(password)
    self.password == password
  end

  private

  def broadcast_room_creation
    puts "ブロードキャストが実行された #{self.room_name}"
    ActionCable.server.broadcast(
      "display_rooms_channel",
      {
        action: "create",
        room_id: self.id,
        room_name: self.room_name,
        host_name: self.host.name,
        created_at: self.created_at.strftime("%Y-%m-%d %H:%M:%S")
      }
    )
  end

  def broadcast_room_deletion
    puts "ルーム削除をブロードキャスト #{self.room_name}"
    ActionCable.server.broadcast(
      "display_rooms_channel",
      {
        action: "delete",
        room_id: self.id,
        room_name: self.room_name
      }
    )
  end
end
