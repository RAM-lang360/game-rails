class JoinUser < ApplicationRecord
  belongs_to :user
  has_many :hosted_rooms, class_name: "Room", foreign_key: "host_id"
end
