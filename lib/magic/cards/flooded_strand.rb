module Magic
  module Cards
    class FloodedStrand < Land
      NAME = "Flooded Strand"

      # "{T}, Pay 1 life, Sacrifice this land: Search your library for a Plains or Island card, put it onto
      # the battlefield, then shuffle."
      class FetchAbility < Magic::ActivatedAbility
        costs "{T}, Pay 1 life, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: ->(card) { card.any_type?("Plains", "Island") }, to: :battlefield)
        end
      end

      def activated_abilities = [FetchAbility]
    end
  end
end
