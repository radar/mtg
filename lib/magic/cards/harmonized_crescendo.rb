module Magic
  module Cards
    HarmonizedCrescendo = Instant("Harmonized Crescendo") do
      cost generic: 4, blue: 2
      convoke
    end

    class HarmonizedCrescendo < Instant
      # Draw a card for each permanent you control of the chosen type.
      class TypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          count = controller.permanents.count { |permanent| permanent.type?(creature_type) }
          trigger_effect(:draw_cards, number_to_draw: count)
        end
      end

      def resolve!
        game.choices.add(TypeChoice.new(actor: self))
      end
    end
  end
end
