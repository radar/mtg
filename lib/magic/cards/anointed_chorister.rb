module Magic
  module Cards
    AnointedChorister = Creature("Anointed Chorister") do
      creature_type("Human Cleric")
      cost white: 1
      power 1
      toughness 1
    end

    class AnointedChorister < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(generic: 4, white: 1)]

        def resolve!
          source.modify_power(3)
          source.modify_toughness(3)

        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
