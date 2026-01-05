module Magic
  module Cards
    SiegeStriker = Creature("Siege Striker") do
      power 1
      toughness 1
      cost white: 1, generic: 2
      creature_type("Human Soldier")
      keywords :indestructible
    end

    class SiegeStriker < Creature
      class PermanentTappedTrigger < TriggeredAbility
        def should_perform?
          return false if event.permanent == actor
          return false unless game.current_turn.active_player == actor.controller
          return false unless event.permanent.creature?
          # Only apply if within attack phase of controller's turn
          game.current_turn.step == "declare_attackers"
        end

        def call
          actor.trigger_effect(
            :modify_power_toughness,
            source: actor,
            target: actor,
            power: 1,
            toughness: 1,
          )
        end
      end

      def event_handlers
        {
          Events::PermanentTapped => PermanentTappedTrigger
        }
      end
    end
  end
end
