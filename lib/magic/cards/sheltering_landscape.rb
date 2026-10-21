module Magic
  module Cards
    ShelteringLandscape = Card("Sheltering Landscape") do
      type "Land"
      # "Cycling {R}{G}{W}"
      cycling({ red: 1, green: 1, white: 1 })
    end

    class ShelteringLandscape < Card
      LAND_TYPES = %w[Mountain Forest Plains].freeze

      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "Search your library for a basic Mountain, Forest, or Plains card, put it onto the battlefield
      # tapped, then shuffle."
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :battlefield,
            enters_tapped: true,
            filter: ->(card) { card.basic_land? && card.any_type?(*LAND_TYPES) },
            prompt: "Search your library for a basic Mountain, Forest, or Plains card. It enters the battlefield tapped."
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
