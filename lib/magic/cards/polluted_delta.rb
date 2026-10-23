module Magic
  module Cards
    class PollutedDelta < Land
      NAME = "Polluted Delta"

      # "{T}, Pay 1 life, Sacrifice this land: Search your library for an Island or Swamp card, put it onto
      # the battlefield, then shuffle."
      class FetchAbility < Magic::ActivatedAbility
        costs "{T}, Pay 1 life, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: ->(card) { card.any_type?("Island", "Swamp") }, to: :battlefield)
        end
      end

      def activated_abilities = [FetchAbility]
    end
  end
end
