module Magic
  module Cards
    MistralSinger = Creature("Mistral Singer") do
      creature_type "Siren"
      cost generic: 2, blue: 1
      power 2
      toughness 2
      keywords :flying
    end

    class MistralSinger < Creature

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
