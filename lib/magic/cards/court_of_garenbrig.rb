module Magic
  module Cards
    CourtOfGarenbrig = Enchantment("Court of Garenbrig") do
      cost generic: 1, green: 2

      enters_the_battlefield do
        controller.become_monarch!
      end
    end

    class CourtOfGarenbrig < Enchantment
      class DistributeCountersChoice < Magic::Choice
        def choices
          game.battlefield.creatures
        end

        def resolve!(distribution: {})
          distribution.each do |target, amount|
            amount.times { add_counter("+1/+1", to: target) }
          end

          return unless controller.monarch?

          controller.creatures.each do |creature|
            existing = creature.counters.of_type(Counters::Plus1Plus1).count
            add_counter("+1/+1", to: creature, amount: existing) if existing.positive?
          end
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.choices.add(DistributeCountersChoice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => UpkeepTrigger
        }
      end
    end
  end
end
