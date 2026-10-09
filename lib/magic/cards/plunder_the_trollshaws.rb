module Magic
  module Cards
    class PlunderTheTrollshaws < Instant
      card_name "Plunder the Trollshaws"
      cost generic: 1, blue: 1
      flashback Costs::Mana.new(generic: 3, blue: 1)

      # `flashback` is true when this spell was cast from the graveyard.
      def resolve!(flashback: false)
        trigger_effect(:draw_cards, source: self, number_to_draw: flashback ? 2 : 1)
      end
    end
  end
end
