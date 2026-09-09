module Magic
  module Cards
    NyxWeaver = Creature("Nyx Weaver") do
      enchantment_creature_type "Spider"
      cost generic: 1, black: 1, green: 1
      power 2
      toughness 3
      keywords :reach
    end

    class NyxWeaver < Creature
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          controller.mill(2)
        end
      end

      class ReturnCardAbility < Magic::ActivatedAbility
        costs "{1}{B}{G}"

        def target_choices
          controller.graveyard.cards
        end

        def resolve!(target:)
          target.move_to_hand!
          trigger_effect(:exile, target: source)
        end
      end

      def event_handlers
        { Events::BeginningOfUpkeep => UpkeepTrigger }
      end

      def activated_abilities = [ReturnCardAbility]
    end
  end
end