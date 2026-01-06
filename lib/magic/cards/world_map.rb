module Magic
  module Cards
    WorldMap = Artifact("World Map") do
      cost generic: 1
    end

    class WorldMap < Artifact
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :hand,
            reveal: true,
            filter: Filter[:basic_lands]
          )
        end
      end

      class LandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :hand,
            reveal: true,
            filter: Filter[:lands]
          )
        end
      end

      class SearchForBasicLand < ActivatedAbility
        costs "{1}, {T}, Sacrifice {this}"

        def resolve!
          game.choices.add(BasicLandChoice.new(actor: source))
        end
      end

      class SearchForLand < ActivatedAbility
        costs "{3}, {T}, Sacrifice {this}"

        def resolve!
          game.choices.add(LandChoice.new(actor: source))
        end
      end

      def activated_abilities = [SearchForBasicLand, SearchForLand]
    end
  end
end
