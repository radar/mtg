module Magic
  module Tokens
    class GoblinWizard < Creature
      POWER = 1
      TOUGHNESS = 1
      NAME = "Goblin Wizard"
      TYPE_LINE = "Token Creature -- Goblin Wizard"

      def colors
        [:red]
      end

      def event_handlers
        {
          Events::SpellCast => -> (receiver, event) do
            KeywordHandlers::Prowess.perform(
              game: game,
              spell: event.spell,
              permanent: receiver
            )
          end
        }
      end

    end
  end
end
