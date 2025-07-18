# app/models/answer.rb
class Answer < ApplicationRecord
  belongs_to :good_ans_game
  
  validates :user_name, presence: true
  validates :content, presence: true
  validates :submitted_at, presence: true
  
  scope :by_submission_order, -> { order(:submitted_at) }
  scope :by_user, ->(user_name) { where(user_name: user_name) }
  
  def to_hash
    { user_name => content }
  end
end