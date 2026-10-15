module Magic
  module Cards
    class UrzasCave < Land
      NAME = "Urza's Cave"

      # "{T}: Add {C}."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{3}, {T}, Sacrifice this land: Search your library for a land card, put it onto the battlefield tapped,
      # then shuffle."
      class SearchAbility < Magic::ActivatedAbility
        costs "{3}, {T}, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: :lands, to: :battlefield, tapped: true)
        end
      end

      def activated_abilities = [ManaAbility, SearchAbility]
    end
  end
end
