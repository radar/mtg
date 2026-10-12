module Magic
  module Cards
    BelladonnaTook = Creature("Belladonna Took") do
      cost generic: 1, white: 1
      legendary_creature_type("Halfling Citizen")
      power 2
      toughness 2
    end

    class BelladonnaTook < Creature
      # How many times the token ability has resolved in `turn` (it counts per turn, so a new turn starts at 0).
      def resolutions_in(turn)
        @resolutions_turn == turn ? @resolutions : 0
      end

      def record_resolution!(turn)
        count = resolutions_in(turn) + 1
        @resolutions_turn = turn
        @resolutions = count
      end

      # "Whenever a token you control enters, you gain 1 life if this is the first time this ability has resolved
      # this turn. If it's the second time, draw a card. If it's the third time, put a +1/+1 counter on each
      # creature you control."
      class TokenEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent.token? && under_your_control?
        end

        def call
          case actor.card.record_resolution!(game.current_turn)
          when 1 then trigger_effect(:gain_life, life: 1)
          when 2 then trigger_effect(:draw_cards, number_to_draw: 1)
          when 3
            controller.creatures.each do |creature|
              trigger_effect(:add_counter, counter_type: "+1/+1", target: creature, amount: 1)
            end
          end
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => TokenEntersTrigger }
    end
  end
end
