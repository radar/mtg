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
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def should_perform?
          super && controller.lands.empty?
        end

        def call
          actor.sacrifice!
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