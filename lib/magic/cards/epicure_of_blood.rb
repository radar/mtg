module Magic
  module Cards
    EpicureOfBlood = Creature("Epicure of Blood") do
      cost generic: 4, black: 1
      creature_type("Vampire")
      power 4
      toughness 4
    end

    class EpicureOfBlood < Creature
      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          opponents = game.opponents(controller)
          opponents.each do |opponent|
            trigger_effect(
              :lose_life,
              source: actor,
              life: 1,
              target: opponent,
            )
          end
        end
      end

      def event_handlers
        {
          # Whenever you gain life, each opponent loses 1 life.
          Events::LifeGain => LifeGainTrigger
        }
      end
    end
  end
end
