module Magic
  module Cards
    TirelessTracker = Creature("Tireless Tracker") do
      cost generic: 2, green: 1
      creature_type "Human Scout"
      power 3
      toughness 2
    end

    class TirelessTracker < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          actor.create_token(token_class: Tokens::Clue)
        end
      end

      class ClueSacrificedTrigger < TriggeredAbility
        def should_perform?
          event.permanent.artifact? && event.permanent.name == "Clue"
        end

        def call
          actor.add_counter("+1/+1")
        end
      end

      def event_handlers
        {
          Events::Landfall => LandfallTrigger,
          Events::PermanentSacrificed => ClueSacrificedTrigger,
        }
      end
    end
  end
end