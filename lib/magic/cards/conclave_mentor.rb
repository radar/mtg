module Magic
  module Cards
    class ConclaveMentor < Creature
      card_name "Conclave Mentor"
      cost "{G}{W}"
      creature_type "Centaur Cleric"
      power 2
      toughness 2

      def replacement_effects
        {
          Effects::AddCounterToPermanent => -> (receiver, effect) do
            # If one or more +1/+1 counters would be put on a creature you control, that many plus one +1/+1 counters are put on that creature instead.
            return effect if effect.counter_type != Counters::Plus1Plus1
            return effect if effect.target.controller != controller
            return effect unless effect.target.creature?

            Effects::AddCounterToPermanent.new(
              source: receiver,
              counter_type: Counters::Plus1Plus1,
              target: effect.target,
              amount: effect.amount + 1,
            )
          end
        }
      end

      class Death < TriggeredAbility::Death
        def perform
          source.trigger_effect(:gain_life, life: source.power)
        end
      end

      def death_triggers = [Death]

    end
  end
end
