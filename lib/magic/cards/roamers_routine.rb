module Magic
  module Cards
    RoamersRoutine = Sorcery("Roamer's Routine") do
      cost generic: 2, green: 1
      harmonize Costs::Mana.new(generic: 4, green: 1)
    end

    class RoamersRoutine < Sorcery
      def resolve!
        game.search_library(self, find: :basic_lands, to: :battlefield, tapped: true)
      end
    end
  end
end
