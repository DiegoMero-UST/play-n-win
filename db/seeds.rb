# Create initial prizes
puts "Creating initial prizes..."
GameCreationService.create_initial_prizes!

# Create a sample game to test
puts "Creating sample game..."
game = GameCreationService.create_game!
puts "Created game with token: #{game.token}"

# Show the card distribution
puts "\nCard distribution:"
game.cards.ordered_by_position.each do |card|
  puts "Position #{card.position}: #{card.prize.name}"
end

puts "\nGame setup complete!"