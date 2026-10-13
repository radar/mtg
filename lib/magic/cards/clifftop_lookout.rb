module Magic
  module Cards
    ClifftopLookout = Creature("Clifftop Lookout") do
      cost generic: 2, green: 1
      creature_type("Frog Scout")
      keywords :reach
      power 1
      toughness 2
    end

    class ClifftopLookout < Creature
      # When this creature enters, reveal cards from the top of your library until you reveal a land card. Put
      # that card onto the battlefield tapped and the rest on the bottom of your library in a random order.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          revealed = []
          land = nil
          controller.library.each do |card|
            revealed << card
            if card.land?
              land = card
              break
            end
          end
          reveal_cards(revealed) if revealed.any?
          if land
            Permanent.put_onto_battlefield(card: land, game: game, from_zone: land.zone, controller: controller, enters_tapped: true)
          end
          (revealed - [land]).shuffle.each do |card|
            controller.library.remove(card)
            controller.library.push(card)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
