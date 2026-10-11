module Magic
  module Cards
    OptimisticScavenger = Creature("Optimistic Scavenger") do
      cost white: 1
      creature_type "Human Scout"
      power 1
      toughness 1
    end

    class OptimisticScavenger < Creature
      class CounterChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target)
        end
      end

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, put a +1/+1 counter
      # on target creature."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          game.add_choice(CounterChoice.new(actor: actor))
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
