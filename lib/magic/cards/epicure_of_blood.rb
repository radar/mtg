module Magic
  module Cards
    EpicureOfBlood = Creature("Epicure of Blood") do
      cost generic: 4, black: 1
      creature_type("Vampire")
      power 4
      toughness 4
    end

    class EpicureOfBlood < Creature

      def target_choices(receiver)
        game.opponents(receiver.controller)
      end

      def event_handlers
        {
          # Whenever you gain life, each opponent loses 1 life.
          Events::LifeGain => -> (receiver, event) do
            return unless event.player == receiver.controller

            trigger_effect(
              :lose_life,
              source: receiver,
              life: 1,
              targets: game.opponents(receiver.controller)
            )
          end
        }
      end
    end
  end
end
