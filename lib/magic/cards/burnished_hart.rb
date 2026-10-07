module Magic
  module Cards
    BurnishedHart = Creature("Burnished Hart") do
      cost generic: 3
      artifact_creature_type("Elk")
      power 2
      toughness 2
    end

    class BurnishedHart < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: :basic_lands, to: :battlefield, tapped: true, upto: 2)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
