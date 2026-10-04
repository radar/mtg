module Magic
  module Cards
    MyriadLandscape = Card("Myriad Landscape") do
      type "Land"
    end

    class MyriadLandscape < Card
      BASIC_LAND_TYPES = %w[Plains Island Swamp Mountain Forest].freeze

      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "Search your library for up to two basic land cards that share a land type, put them onto the
      # battlefield tapped, then shuffle."
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: 2, filter: Filter[:basic_lands])
        end

        def resolve!(targets:)
          targets = Array(targets)
          if targets.size == 2 && BASIC_LAND_TYPES.none? { |type| targets.all? { _1.type?(type) } }
            raise ArgumentError, "#{targets.map(&:name).join(' and ')} don't share a land type"
          end

          super(targets:)
        end
      end

      class SearchAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def resolve!
          game.add_choice(BasicLandChoice.new(actor: source))
        end
      end

      def activated_abilities = [ManaAbility, SearchAbility]
    end
  end
end
