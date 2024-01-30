module Magic
  module Cards
    IgneousCur = Creature("Igneous Cur") do
      cost "{1}{R}"
      creature_type("Elemental Dog")
      power 1
      toughness 2
    end

    class IgneousCur < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new(red: 1, generic: 1)]
        end

        def resolve!
          source.modify_power(2)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
