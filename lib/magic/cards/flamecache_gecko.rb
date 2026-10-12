module Magic
  module Cards
    FlamecacheGecko = Creature("Flamecache Gecko") do
      cost generic: 1, red: 1
      creature_type("Lizard Warlock")
      power 2
      toughness 2
    end

    class FlamecacheGecko < Creature
      # When this creature enters, if an opponent lost life this turn, add {B}{R}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = game.current_turn.opponent_lost_life?(controller)

        def call
          controller.add_mana(black: 1, red: 1)
        end
      end

      def etb_triggers = [EntersTrigger]

      # {1}{R}, Discard a card: Draw a card.
      class LootAbility < Magic::ActivatedAbility
        costs "{1}{R}, Discard a card"

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def activated_abilities = [LootAbility]
    end
  end
end
