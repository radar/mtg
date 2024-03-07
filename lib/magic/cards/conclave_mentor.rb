module Magic
  module Cards
    class ConclaveMentor < Creature
      card_name "Conclave Mentor"
      cost "{G}{W}"
      creature_type "Centaur Cleric"
      power 2
      toughness 2

      class AddMoreCounters < ReplacementEffect
        def applies?(effect)
          effect.counter_type == Counters::Plus1Plus1 &&
            effect.target.controller == receiver.controller &&
            effect.target.creature?
        end

        def call(effect)
          Effects::AddCounterToPermanent.new(
            source: receiver,
            counter_type: Counters::Plus1Plus1,
            target: effect.target,
            amount: effect.amount + 1,
          )
        end
      end

      def replacement_effects
        {
          Effects::AddCounterToPermanent => AddMoreCounters,
        }
      end

      class Death < TriggeredAbility::Death
        def perform
          actor.trigger_effect(:gain_life, life: actor.power)
        end
      end

      def death_triggers = [Death]

    end
  end
end
