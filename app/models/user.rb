class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :hosted_rooms, class_name: "Room", foreign_key: "host_id"
  validates :name, presence: true, uniqueness: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
