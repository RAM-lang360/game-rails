class GoodAnsGame < ApplicationRecord
  belongs_to :room

  validates :status, inclusion: { in: %w[waiting playing finished] }

  def draw_theme!
    return nil if themes.empty?

    drawn = themes.shift
    self.current_theme = drawn
    save!
    drawn
  end

  def remaining_themes_count
    themes.size
  end

  def initialize_themes!
    self.themes = AnsTheme.pluck(:text).shuffle
    self.status = "waiting"
    save!
  end
end
