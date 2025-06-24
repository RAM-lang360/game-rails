class Room < ApplicationRecord
  # room.hostでホストの情報を取得できるようにする
  belongs_to :host

  # has_many :cards, dependent: :destroy
end
