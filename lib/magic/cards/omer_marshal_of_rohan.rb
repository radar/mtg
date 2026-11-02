module Magic
  module Cards
    OmerMarshalOfRohan = Creature("Éomer, Marshal of Rohan") do
      cost generic: 2, red: 2
      legendary_creature_type "Human Knight"
      power 4
      toughness 4
      keywords :haste
    end

    class OmerMarshalOfRohan < Creature
      # "Whenever one or more other attacking legendary creatures you control die, untap all creatures you control.
      # After this phase, there is an additional combat phase. This ability triggers only once each turn."
      # Creatures that die together each send an event, but the once-per-turn mark set by the first one stops the rest,
      # so a simultaneous group gives one trigger (CR 603.2c).
      class LegendaryAttackerDiedTrigger < TriggeredAbility
        def trigger!
          return false unless should_perform? && !actor.triggered_once_this_turn?(self.class)

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def should_perform?
          dead = event.permanent
          dead != actor && dead.legendary? && event.controller == controller &&
            !!game.current_turn.combat&.attacking?(dead)
        end

        def call
          controller.creatures.each(&:untap!)
          game.current_turn.queue_additional_combat!
        end
      end

      def event_handlers = { Events::CreatureDied => LegendaryAttackerDiedTrigger }
    end
  end
end
