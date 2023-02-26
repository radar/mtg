module Magic
  module Cards
    JeskaiElder = Creature("Jeskai Elder") do
      creature_type "Human Monk"
      power 1
      toughness 2
    end

    class JeskaiElder < Creature

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
