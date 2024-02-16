module Magic
  module Cards
    NineLives = Enchantment("Nine Lives") do
      cost generic: 1, white: 2
      keywords :hexproof
    end

    class NineLives < Enchantment
      class LTB < TriggeredAbility::EnterTheBattlefield
        def perform
          actor.trigger_effect(:lose_game, player: controller)
        end
      end

      def replacement_effects
        {
          Effects::LoseLife => -> (receiver, event) do
            Effects::AddCounterToPermanent.new(
              source: receiver,
              counter_type: Counters::Incarnation,
              target: receiver,
            )
          end
        }
      end

      def event_handlers
        {
          Events::CounterAddedToPermanent => -> (receiver, event) do
            if receiver.counters.of_type(Counters::Incarnation).count >= 9
              trigger_effect(:exile, target: receiver)
            end
          end
        }
      end

      def ltb_triggers = [LTB]
    end
  end
end
