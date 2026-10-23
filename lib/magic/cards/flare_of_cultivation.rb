module Magic
  module Cards
    FlareOfCultivation = Sorcery("Flare of Cultivation") do
      cost generic: 1, green: 2
    end

    class FlareOfCultivation < Sorcery
      # "You may sacrifice a nontoken green creature rather than pay this spell's mana cost."
      def alternative_cost = Costs::SacrificeCreatureAlternativeCost.new(color: :green)

      # "Search your library for up to two basic land cards, reveal those cards, put one onto the battlefield tapped and
      # the other into your hand, then shuffle." Two searches: the first lands tapped, the second goes to hand.
      def resolve!
        game.search_library(self, find: :basic_lands, to: :battlefield, tapped: true, reveal: true)
        game.search_library(self, find: :basic_lands, to: :hand, reveal: true)
      end
    end
  end
end
