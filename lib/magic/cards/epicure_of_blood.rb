module Magic
  module Cards
    EpicureOfBlood = Creature("Epicure of Blood") do
      cost generic: 4, black: 1
      type "Creature -- Vampire"
      power 4
      toughness 4
    end

    class EpicureOfBlood < Creature
      def event_handlers
        {
          # Whenever you gain life, each opponent loses 1 life.
          Events::LifeGain => -> (receiver, event) do
            return unless event.player == receiver.controller

            game.deal_damage_to_opponents(event.player, 1)
          end
        }
      end
    end
  end
end
