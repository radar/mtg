module Magic
  module Cards
    SeethingLandscape = Card("Seething Landscape") do
      type "Land"
      # "Cycling {U}{B}{R}"
      cycling({ blue: 1, black: 1, red: 1 })
    end

    class SeethingLandscape < Card
      LAND_TYPES = %w[Island Swamp Mountain].freeze

      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "Search your library for a basic Island, Swamp, or Mountain card, put it onto the battlefield
      # tapped, then shuffle."
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :battlefield,
            enters_tapped: true,
            filter: ->(card) { card.basic_land? && card.any_type?(*LAND_TYPES) },
            prompt: "Search your library for a basic Island, Swamp, or Mountain card. It enters the battlefield tapped."
          )
        end
      end

      class SearchAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.add_choice(SearchChoice.new(actor: source))
        end
      end

      def activated_abilities = [ManaAbility, SearchAbility]
    end
  end
end
