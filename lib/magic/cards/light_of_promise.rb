module Magic
  module Cards
    class LightOfPromise < Aura
      card_name "Light of Promise"
      cost "{2}{W}"

      # ...

      def target_choices
        battlefield.creatures
      end

      class LifeGain < TriggeredAbility::Base
        def should_perform?
          event.player == controller
        end

        def call
          actor.attached_to.add_counter(counter_type: Counters::Plus1Plus1, amount: event.life)
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
