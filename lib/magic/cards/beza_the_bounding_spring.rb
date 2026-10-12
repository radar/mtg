module Magic
  module Cards
    BezaTheBoundingSpring = Creature("Beza, the Bounding Spring") do
      legendary_creature_type "Elemental Elk"
      cost generic: 2, white: 2
      power 4
      toughness 5
    end

    class BezaTheBoundingSpring < Creature
      # When Beza enters, create a Treasure token if an opponent controls more lands than you. You gain 4 life if
      # an opponent has more life than you. Create two 1/1 blue Fish creature tokens if an opponent controls more
      # creatures than you. Draw a card if an opponent has more cards in hand than you.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure) if opponents.any? { _1.lands.count > controller.lands.count }
          trigger_effect(:gain_life, life: 4) if opponents.any? { _1.life > controller.life }
          trigger_effect(:create_token, token_class: Tokens::Fish, amount: 2) if opponents.any? { _1.creatures.count > controller.creatures.count }
          trigger_effect(:draw_cards, number_to_draw: 1) if opponents.any? { _1.hand.count > controller.hand.count }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
