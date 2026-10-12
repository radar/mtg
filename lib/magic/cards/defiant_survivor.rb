module Magic
  module Cards
    DefiantSurvivor = Creature("Defiant Survivor") do
      cost generic: 2, green: 1
      creature_type "Human Survivor"
      power 3
      toughness 2
    end

    class DefiantSurvivor < Creature
      # "Survival -- At the beginning of your second main phase, if this creature is tapped, manifest dread."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
