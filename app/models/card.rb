class Card < ApplicationRecord
  belongs_to :game
  belongs_to :prize
  
  validates :position, presence: true, numericality: { in: 1..10 }
  validates :game_id, uniqueness: { scope: :position }
  
  scope :by_position, ->(pos) { where(position: pos) }
  scope :ordered_by_position, -> { order(:position) }
end
