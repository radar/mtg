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
          if_an_opponent_has_more(:lands) { create_token Tokens::Treasure }
          if_an_opponent_has_more(:life) { trigger_effect(:gain_life, life: 4) }
          if_an_opponent_has_more(:creatures) { create_token Tokens::Fish, amount: 2 }
          if_an_opponent_has_more(:hand) { draw_cards }
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
