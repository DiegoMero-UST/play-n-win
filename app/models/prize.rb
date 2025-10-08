class Prize < ApplicationRecord
  has_many :cards, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  
  scope :active, -> { where(active: true) }
  
  def self.create_prize_distribution!
    # Create the initial prize distribution
    prizes_data = [
      { name: "Coloring Book", description: "Fun coloring book for kids" },
      { name: "Tape Measurer", description: "Useful tape measurer tool" },
      { name: "Phone Stand", description: "Adjustable phone stand" },
      { name: "Coffee Mug", description: "Premium coffee mug" },
      { name: "Gift Card", description: "Digital gift card" }
    ]
    
    prizes_data.each do |prize_data|
      find_or_create_by(name: prize_data[:name]) do |prize|
        prize.description = prize_data[:description]
        prize.active = true
      end
    end
  end
end
