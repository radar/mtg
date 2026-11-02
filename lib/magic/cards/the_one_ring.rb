module Magic
  module Cards
    TheOneRing = Artifact("The One Ring") do
      type T::Super::Legendary, T::Artifact
      cost generic: 4
      keywords :indestructible
    end

    class TheOneRing < Artifact
      # "When The One Ring enters, if you cast it, you gain protection from everything until your next turn."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = this? && actor.cast?

        def call
          controller.gain_protection_from_everything_until_next_turn!
        end
      end

      # "At the beginning of your upkeep, you lose 1 life for each burden counter on The One Ring."
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          burdens = actor.counters.of_type(Magic::Counters::Burden).count
          lose_life(controller, burdens) if burdens.positive?
        end
      end

      # "{T}: Put a burden counter on The One Ring, then draw a card for each burden counter on The One Ring."
      class BurdenAbility < Magic::ActivatedAbility
        def costs = [Costs::SelfTap.new(source)]

        def resolve!
          source.add_counter(Magic::Counters::Burden)
          draw_cards(source.counters.of_type(Magic::Counters::Burden).count)
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }

      def activated_abilities = [BurdenAbility]
    end
  end
end
