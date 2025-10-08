class Player < ApplicationRecord
  belongs_to :game
  has_one :prize_submission, dependent: :destroy
  
  validates :picked_card, presence: true, numericality: { in: 1..10 }
  validates :game_id, uniqueness: true
  
  def won_prize
    game.cards.find_by(position: picked_card)&.prize
  end
  
  def has_submitted_form?
    prize_submission.present?
  end
end
