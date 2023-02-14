module Magic
  module Cards
    class EpicureOfBlood < Card
      NAME = "Epicure of Blood"
      COST = { any: 4, black: 1}
      TYPE_LINE = creature_type("Vampire")

      def target_choices(permanent)
        permanent.game.opponents(permanent.controller)
      end

      def event_handlers
        {
          # Whenever you gain life, each opponent loses 1 life.
          Events::LifeGain => -> (receiver, event) do
            return unless event.player == receiver.controller

            effect = Effects::DealDamageToOpponents.new(source: receiver, damage: 1)
            effect.resolve(game.opponents(receiver.controller))
          end
        }
      end

    end
  end
end
