class Game < ApplicationRecord
  has_many :cards, dependent: :destroy
  has_one :player, dependent: :destroy
  
  validates :token, presence: true, uniqueness: true
  
  before_validation :generate_token, on: :create
  
  def won_prize
    return nil unless played? && player&.picked_card
    cards.find_by(position: player.picked_card)&.prize
  end
  
  def can_be_played?
    !played?
  end
  
  def mark_as_played!(card_position)
    return false if played?
    
    transaction do
      update!(played: true, played_at: Time.current)
      create_player!(picked_card: card_position, picked_at: Time.current)
    end
  end
  
  def mark_form_submitted!
    update!(form_submitted: true, form_submitted_at: Time.current)
  end
  
  private
  
  def generate_token
    self.token = SecureRandom.urlsafe_base64(32) if token.blank?
  end
end
