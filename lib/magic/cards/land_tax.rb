module Magic
  module Cards
    class LandTax < Enchantment
      card_name "Land Tax"
      cost white: 1

      class UpkeepChoice < Magic::Choice::May
        def resolve!
          game.add_choice(SearchChoice.new(actor: actor))
        end
      end

      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, upto: 3, to_zone: :hand, filter: Filter[:basic_lands])
        end
      end

      class BeginningOfYourUpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def should_perform?
          opponent_controls_more_lands = game.opponents(controller).any? { _1.lands.count > controller.lands.count }
          super && opponent_controls_more_lands
        end

        def call
          game.add_choice(UpkeepChoice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => BeginningOfYourUpkeepTrigger
        }
      end
    end
  end
end
