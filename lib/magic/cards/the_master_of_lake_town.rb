module Magic
  module Cards
    TheMasterOfLakeTown = Creature("The Master of Lake-town") do
      cost generic: 1, black: 2
      legendary_creature_type "Human Advisor"
      keywords :deathtouch
      power 3
      toughness 2
    end

    class TheMasterOfLakeTown < Creature
      # "Whenever a player loses life, that player mills that many cards."
      class LifeLossTrigger < TriggeredAbility
        def should_perform?
          event.life.positive?
        end

        def call
          event.player.mill(event.life)
        end
      end

      def event_handlers = super.merge({ Events::LifeLoss => LifeLossTrigger }) { |_, old, new| [*old, *new] }

      # "When The Master of Lake-town dies, draw a card for each graveyard with seven or more cards in it."
      class DiesTrigger < TriggeredAbility::Death
        def call
          count = game.players.count { _1.graveyard.count >= 7 }
          trigger_effect(:draw_cards, number_to_draw: count) if count.positive?
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
