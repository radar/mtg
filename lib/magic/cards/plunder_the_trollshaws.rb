module Magic
  module Cards
    class PlunderTheTrollshaws < Instant
      card_name "Plunder the Trollshaws"
      cost generic: 1, blue: 1
      flashback Costs::Mana.new(generic: 3, blue: 1)

      # `flashback` is true when this spell was cast from the graveyard.
      def resolve!(flashback: false)
        draw_cards(flashback ? 2 : 1)
      end
    end
  end
end
