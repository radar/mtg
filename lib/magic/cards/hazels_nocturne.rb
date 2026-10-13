module Magic
  module Cards
    HazelsNocturne = Instant("Hazel's Nocturne") do
      cost generic: 3, black: 1
    end

    class HazelsNocturne < Instant
      def target_choices
        controller.graveyard.cards.select { _1.type?("Creature") }
      end

      def resolve!(targets:)
        targets.uniq.each { _1.move_to_hand! }
        game.opponents(controller).each { lose_life(_1, 2) }
        gain_life(2)
      end
    end
  end
end
