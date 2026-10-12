module Magic
  module Cards
    TheGitrogMonster = Creature("The Gitrog Monster") do
      legendary_creature_type "Frog Horror"
      cost generic: 3, black: 1, green: 1
      power 6
      toughness 6
      keywords :deathtouch
    end

    class TheGitrogMonster < Creature
      # "At the beginning of your upkeep, sacrifice The Gitrog Monster unless you sacrifice a land."
      # Accepting sacrifices the chosen land; declining sacrifices The Gitrog Monster.
      class SacrificeLandChoice < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice a land? If you don't, sacrifice The Gitrog Monster."

        def initialize(actor:)
          super(actor: actor, type: "Land", other: false)
        end

        def decline!
          actor.sacrifice!
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          if controller.permanents.any? { _1.type?("Land") }
            game.add_choice(SacrificeLandChoice.new(actor: actor))
          else
            actor.sacrifice!
          end
        end
      end

      class LandPutIntoGraveyardTrigger < TriggeredAbility
        def should_perform?
          event.permanent.land? && event.to.graveyard?
        end

        def call
          controller.draw!
        end
      end

      def additional_lands_per_turn = 1

      def event_handlers
        {
          Events::BeginningOfUpkeep => UpkeepTrigger,
          Events::PermanentLeavingZone => LandPutIntoGraveyardTrigger,
        }
      end
    end
  end
end