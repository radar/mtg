module Magic
  module Cards
    PortcullisVine = Creature("Portcullis Vine") do
      cost green: 1
      power 0
      toughness 3
      creature_type "Plant Wall"
      keywords :defender
    end

    class PortcullisVine < Creature
      class DrawCardAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice a creature with defender"

        def resolve!
          source.controller.draw!
        end
      end

      def activated_abilities = [DrawCardAbility]
    end
  end
end
