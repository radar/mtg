module Magic
  module Cards
    NineLives = Enchantment("Nine Lives") do
      cost generic: 1, white: 2
      keywords :hexproof
    end

    class NineLives < Enchantment
      class PreventDamage < ReplacementEffect
        def applies?(effect)
          effect.target == receiver.controller
        end

        def call(effect)
          Effects::AddCounterToPermanent.new(
            source: receiver,
            counter_type: Counters::Incarnation,
            target: receiver,
          )
        end
      end

      class LTB < TriggeredAbility::EnterTheBattlefield
        def perform
          actor.trigger_effect(:lose_game, player: controller)
        end
      end

      class CounterAddedHandler < TriggeredAbility
        def should_perform?
          actor.counters.of_type(Counters::Incarnation).count >= 9
        end

        def call
          actor.trigger_effect(:exile, target: actor)
        end
      end

      def replacement_effects
        {
          Effects::DealDamage => PreventDamage,
          Effects::DealCombatDamage => PreventDamage,
        }
      end

      def event_handlers
        {
          Events::CounterAddedToPermanent => CounterAddedHandler
        }
      end

      def ltb_triggers = [LTB]
    end
  end
end
