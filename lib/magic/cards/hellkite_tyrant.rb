module Magic
  module Cards
    HellkiteTyrant = Creature("Hellkite Tyrant") do
      cost generic: 4, red: 2
      creature_type "Dragon"
      keywords :flying, :trample
      power 6
      toughness 5
    end

    class HellkiteTyrant < Creature
      # "Whenever this creature deals combat damage to a player, gain control of all artifacts that player controls."
      class StealArtifactsTrigger < TriggeredAbility
        def should_perform?
          event.combat? && event.source == actor && event.target.player?
        end

        def call
          event.target.permanents.select { |permanent| permanent.type?("Artifact") }.each do |artifact|
            artifact.controller = controller
          end
        end
      end

      # "At the beginning of your upkeep, if you control twenty or more artifacts, you win the game."
      class UpkeepWinTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def should_perform?
          super && controller.permanents.count { |permanent| permanent.type?("Artifact") } >= 20
        end

        def call
          opponents.each(&:lose!)
        end
      end

      def event_handlers
        {
          Events::DamageDealt => StealArtifactsTrigger,
          Events::BeginningOfUpkeep => UpkeepWinTrigger,
        }
      end
    end
  end
end
