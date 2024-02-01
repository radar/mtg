module Magic
  module Cards
    PalladiumMyr = Creature("Palladium Myr") do
      artifact_creature_type "Myr"
      power 2
      toughness 2
    end

    class PalladiumMyr < Creature
      class ManaAbility < ManaAbility
        def costs
          [
            Costs::Tap.new(source)
          ]
        end

        def resolve!
          source.controller.add_mana(generic: 2)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
