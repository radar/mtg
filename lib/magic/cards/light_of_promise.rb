module Magic
  module Cards
    class LightOfPromise < Aura
      NAME = "Light of Promise"
      COST = { generic: 2, white: 1 }

      def target_choices
        battlefield.creatures
      end

      def event_handlers
        {
          # Whenever you gain life, put that many +1/+1 counters on this creature.”
          Events::LifeGain => -> (receiver, event) do
            return unless event.player == receiver.controller
            receiver.attached_to.add_counter(Counters::Plus1Plus1, amount: event.life)
          end
        }
      end
    end
  end
end
