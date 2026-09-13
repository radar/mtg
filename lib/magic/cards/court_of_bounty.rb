module Magic
  module Cards
    CourtOfBounty = Enchantment("Court of Bounty") do
      cost generic: 2, green: 2

      enters_the_battlefield do
        controller.become_monarch!
      end
    end

    class CourtOfBounty < Enchantment
      class PutCardChoice < Magic::Choice::Targeted
        def choices
          if controller.monarch?
            hand.by_any_type("Land", "Creature")
          else
            hand.lands
          end
        end

        def resolve!(target:)
          target.resolve!
        end
      end

      class MayPutCardChoice < Magic::Choice::May
        def resolve!
          game.choices.add(PutCardChoice.new(actor: actor))
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.choices.add(MayPutCardChoice.new(actor: actor))
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
