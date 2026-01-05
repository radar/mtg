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
      class LandfallTrigger < TriggeredAbility
        def should_perform?


      def event_handlers
        {
          Events::PermanentTapped => -> (receiver, event) do
            return if event.permanent == receiver
            # TODO: Only apply if within attack phase of controller's turn
            return unless game.current_turn.active_player == receiver.controller
            return unless game.current_turn.step?(:declare_attackers)
            return unless event.permanent.creature?

            receiver.trigger_effect(
              :modify_power_toughness,
              source: receiver,
              target: receiver,
              power: 1,
              toughness: 1,
            )

          end
        }
      end
    end
  end
end
