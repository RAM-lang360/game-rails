class Room < ApplicationRecord
  # host_idカラムがUserモデルを参照することを明示
  belongs_to :host, class_name: "User", foreign_key: "host_id"
  # join_idカラムがJoinUserモデルを参照することを明示
  belongs_to :join_user, foreign_key: :join_id, optional: true
  # null: false なので optional: true は不要
end
