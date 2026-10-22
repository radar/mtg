module Magic
  module Cards
    # The land back face of Waterlogged Teachings. It has no mana cost.
    InundatedArchive = Card("Inundated Archive") do
      type "Land"
    end

    class InundatedArchive < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :black
      end

      def activated_abilities = [ManaAbility]
    end

    WaterloggedTeachings = Instant("Waterlogged Teachings") do
      cost "{3}{U/B}"
      back_face InundatedArchive
    end

    class WaterloggedTeachings < Instant
      # "Search your library for an instant card or a card with flash, reveal it, put it into your hand, then
      # shuffle."
      def resolve!
        game.search_library(self, find: ->(card) { card.instant? || card.flash? }, to: :hand, reveal: true,
          prompt: "Search your library for an instant card or a card with flash. Put it into your hand.")
      end
    end
  end
end
