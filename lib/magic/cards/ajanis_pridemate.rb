module Magic
  module Cards
    class AjanisPridemate < Creature
      card_name "Ajani's Pridemate"
      creature_type "Cat Soldier"
      cost "{1}{W}"
      power 2
      toughness 2

      class LifeGain < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          actor.trigger_effect(
            :add_counter,
            target: actor,
            counter_type: Counters::Plus1Plus1,
            amount: event.life
          )
        end
      end

      def event_handlers
        {
          # Whenever you gain life, put that many +1/+1 counters on this creature.”
          Events::LifeGain => LifeGain
        }
      end
    end
  end
end
