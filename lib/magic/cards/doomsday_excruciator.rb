module Magic
  module Cards
    DoomsdayExcruciator = Creature("Doomsday Excruciator") do
      cost "{B}{B}{B}{B}{B}{B}"
      creature_type "Demon"
      keywords :flying
      power 6
      toughness 6
    end

    class DoomsdayExcruciator < Creature
      KEPT_CARDS = 6

      # "When this creature enters, if it was cast, each player exiles all but the bottom six cards of their library
      # face down." (The engine has no face-down exile; nothing later reads the cards, so they are just exiled.)
      class ExileTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          this? && actor.cast?
        end

        def call
          game.players.each do |player|
            excess = player.library.count - KEPT_CARDS
            player.library.first(excess).each(&:exile!) if excess.positive?
          end
        end
      end

      # "At the beginning of your upkeep, draw a card."
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => ExileTrigger,
          Events::BeginningOfUpkeep => UpkeepTrigger
        }
      end
    end
  end
end
