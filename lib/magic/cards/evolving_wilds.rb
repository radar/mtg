module Magic
  module Cards
    class EvolvingWilds < Land
      NAME = "Evolving Wilds"

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: :basic_lands, to: :battlefield, tapped: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
