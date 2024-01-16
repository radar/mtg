# Frantic Inventory {1}{U}
# Instant
# Draw a card, then draw cards equal to the number of cards named Frantic Inventory in your graveyard.

module Magic
  module Cards
    FranticInventory = Instant("Frantic Inventory") do
      cost generic: 1, blue: 1

      def resolve!
        owner.draw!
        owner.graveyard.by_card(self).each do |card|
          owner.draw!
        end
      end
    end
  end
end
