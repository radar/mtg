module Magic
  module Cards
    CautiousSurvivor = Creature("Cautious Survivor") do
      cost generic: 3, green: 1
      creature_type "Elf Survivor"
      power 4
      toughness 4
    end

    class CautiousSurvivor < Creature
      # "Survival — At the beginning of your second main phase, if this creature is tapped, you gain 2 life."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
