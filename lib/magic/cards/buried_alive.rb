module Magic
  module Cards
    BuriedAlive = Sorcery("Buried Alive") do
      cost generic: 2, black: 1
    end

    class BuriedAlive < Sorcery
      # "Search your library for up to three creature cards, put them into your graveyard, then shuffle."
      def resolve!
        game.search_library(self, find: "Creature", to: :graveyard, upto: 3)
      end
    end
  end
end
