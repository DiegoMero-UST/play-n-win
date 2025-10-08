class GameCreationService
  PRIZE_DISTRIBUTION = {
    "Coloring Book" => 4,
    "Tape Measurer" => 2,
    "Phone Stand" => 2,
    "Coffee Mug" => 1,
    "Gift Card" => 1
  }.freeze
  
  def self.create_game!
    ActiveRecord::Base.transaction do
      # Create the game
      game = Game.create!
      
      # Get all active prizes
      prizes = Prize.active
      
      # Create prize distribution array
      prize_distribution = []
      PRIZE_DISTRIBUTION.each do |prize_name, count|
        prize = prizes.find_by(name: prize_name)
        next unless prize
        
        count.times { prize_distribution << prize }
      end
      
      # Shuffle the distribution to randomize positions
      prize_distribution.shuffle!
      
      # Create cards for each position
      (1..10).each do |position|
        prize = prize_distribution[position - 1]
        game.cards.create!(
          position: position,
          prize: prize
        )
      end
      
      game
    end
  end
  
  def self.create_initial_prizes!
    Prize.create_prize_distribution!
  end
end
